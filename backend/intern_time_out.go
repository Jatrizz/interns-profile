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
		UserID  int    `json:"user_id"`
		Remarks string `json:"remarks"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		jsonError(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	if req.UserID == 0 {
		jsonError(w, "user_id is required", http.StatusBadRequest)
		return
	}

	now := time.Now()

	// Find the active session (timed in but no time_out yet) for today
	var logID int
	var timeInStr string
	var currentStatus string
	var session string
	err := db.QueryRow(`
		SELECT id, time_in, status, session
		FROM time_logs
		WHERE user_id = $1
		AND log_date = CURRENT_DATE
		AND time_out IS NULL
		AND status != 'no_timeout'
		ORDER BY time_in DESC
		LIMIT 1
	`, req.UserID).Scan(&logID, &timeInStr, &currentStatus, &session)
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

	// Calculate hours rendered (clamped to session window automatically)
	hoursRendered := calculateHoursRendered(timeIn, now)

	// Determine final status
	// half-day: only if morning session AND clocking out before 12PM
	// For afternoon session, clocking out early doesn't change status to half-day
	finalStatus := currentStatus
	morningEnd := time.Date(now.Year(), now.Month(), now.Day(), 12, 0, 0, 0, now.Location())
	if session == "morning" && now.Before(morningEnd) {
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
		"session":         session,
		"time_out":        now.Format("15:04:05"),
		"hours_rendered":  hoursRendered,
		"total_rendered":  totalRendered,
		"required_hours":  requiredHours,
		"remaining_hours": remainingHours,
		"status":          finalStatus,
	})
}
