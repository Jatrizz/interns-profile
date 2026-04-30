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
		UserID  string `json:"user_id"`
		Remarks string `json:"remarks"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		jsonError(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	if req.UserID == "" {
		jsonError(w, "user_id is required", http.StatusBadRequest)
		return
	}

	now := time.Now()

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

	parsedTimeIn, err := time.Parse("15:04:05", timeInStr)
	if err != nil {
		jsonError(w, "Error parsing time in", http.StatusInternalServerError)
		return
	}
	timeIn := time.Date(now.Year(), now.Month(), now.Day(),
		parsedTimeIn.Hour(), parsedTimeIn.Minute(), parsedTimeIn.Second(), 0, now.Location())

	lunchStart := time.Date(now.Year(), now.Month(), now.Day(), 12, 0, 0, 0, now.Location())
	lunchEnd := time.Date(now.Year(), now.Month(), now.Day(), 13, 0, 0, 0, now.Location())

	// Clock-in was during lunch AND clocking out before 1PM = absent
	if !timeIn.Before(lunchStart) && now.Before(lunchEnd) {
		_, err = db.Exec(`
			UPDATE time_logs
			SET time_out = $1,
			    hours_rendered = 0,
			    status = 'absent',
			    remarks = $2
			WHERE id = $3
		`, now.Format("15:04:05"), req.Remarks, logID)
		if err != nil {
			jsonError(w, "Failed to record time out", http.StatusInternalServerError)
			return
		}
		json.NewEncoder(w).Encode(map[string]interface{}{
			"message":        "Marked as absent",
			"time_out":       now.Format("15:04:05"),
			"hours_rendered": 0,
			"status":         "absent",
		})
		return
	}

	finalStatus := currentStatus

	noon := time.Date(now.Year(), now.Month(), now.Day(), 12, 0, 0, 0, now.Location())
	onePM := time.Date(now.Year(), now.Month(), now.Day(), 13, 0, 0, 0, now.Location())
	fivePM := time.Date(now.Year(), now.Month(), now.Day(), 17, 0, 0, 0, now.Location())

	// GENERAL RULE: Early timeout (before 1PM) = HALF DAY
	// BUT only if time-in is BEFORE lunch
	if timeIn.Before(noon) && now.Before(onePM) {
		finalStatus = "half day"
	}

	// CASE 1: 12PM+ time-in + timeout < 1PM → ABSENT
	if !timeIn.Before(noon) && now.Before(onePM) {
		finalStatus = "absent"
	}

	// CASE 2: 12PM+ time-in + timeout 1PM–5PM → HALF DAY
	if !timeIn.Before(noon) && (now.After(onePM) || now.Equal(onePM)) && now.Before(fivePM) {
		finalStatus = "half day"
	}

	hoursRendered := calculateHoursRendered(timeIn, now)

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