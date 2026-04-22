package main

import (
	"encoding/json"
	"net/http"
	"time"
)

func InternTimeOut(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	w.Header().Set("Content-Type", "application/json")

	var req struct {
		UserID  string `json:"user_id"` // ← string
		Remarks string `json:"remarks"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		jsonError(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	if req.UserID == "" { // ← empty string check
		jsonError(w, "user_id is required", http.StatusBadRequest)
		return
	}

	now := time.Now()

	// Find active time in for today
	var logID int
	var timeInStr string
	var currentStatus string
	err := db.QueryRow(`
    SELECT id, time_in::text, status
    FROM time_logs
    WHERE user_id = $1
    AND log_date = CURRENT_DATE
    AND time_out IS NULL
    ORDER BY time_in DESC
    LIMIT 1
`, req.UserID).Scan(&logID, &timeInStr, &currentStatus)
	if err != nil {
		jsonError(w, "No active time in found for today", http.StatusNotFound)
		return
	}

	// Reconstruct timeIn with today's date
	parsedTimeIn, err := time.Parse("15:04:05", timeInStr)
	if err != nil {
		jsonError(w, "Error parsing time in", http.StatusInternalServerError)
		return
	}
	timeIn := time.Date(now.Year(), now.Month(), now.Day(),
		parsedTimeIn.Hour(), parsedTimeIn.Minute(), parsedTimeIn.Second(), 0, now.Location())

	hoursRendered := calculateHoursRendered(timeIn, now)

	// half-day if clocking out before 1PM
	finalStatus := currentStatus
	halfDayCutoff := time.Date(now.Year(), now.Month(), now.Day(), 13, 0, 0, 0, now.Location())
	if now.Before(halfDayCutoff) {
		finalStatus = "half-day"
	}

	_, err = db.Exec(`
		UPDATE time_logs
		SET time_out = $1,
		    hours_rendered = $2,
		    status = $3,
		    remarks = $4
		WHERE id = $5
	`, now.Format("15:04:05"), hoursRendered, finalStatus, req.Remarks, logID)
	if err != nil {
		jsonError(w, "Failed to record time out", http.StatusInternalServerError)
		return
	}

	// Get updated totals
	var requiredHours float64
	var totalRendered float64
	err = db.QueryRow(`
		SELECT
		    ip.required_ojt_hours,
		    COALESCE(SUM(tl.hours_rendered), 0)
		FROM intern_profiles ip
		LEFT JOIN time_logs tl ON tl.user_id = ip.user_id
		WHERE ip.user_id = $1
		GROUP BY ip.required_ojt_hours
	`, req.UserID).Scan(&requiredHours, &totalRendered)
	if err != nil {
		jsonError(w, "Error getting remaining hours", http.StatusInternalServerError)
		return
	}

	remainingHours := requiredHours - totalRendered
	if remainingHours < 0 {
		remainingHours = 0
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"message":         "Time out recorded successfully",
		"time_out":        now.Format("15:04:05"),
		"hours_rendered":  hoursRendered,
		"total_rendered":  totalRendered,
		"required_hours":  requiredHours,
		"remaining_hours": remainingHours,
		"status":          finalStatus,
	})
}
