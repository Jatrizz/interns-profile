package main

import (
	"encoding/json"
	"net/http"
	"time"
)

func InternTimeIn(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	w.Header().Set("Content-Type", "application/json")

	var req struct {
		UserID int `json:"user_id"`
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

	// Determine which session based on current time
	morningStart := time.Date(now.Year(), now.Month(), now.Day(), 8, 0, 0, 0, now.Location())
	morningEnd := time.Date(now.Year(), now.Month(), now.Day(), 12, 0, 0, 0, now.Location())
	afternoonStart := time.Date(now.Year(), now.Month(), now.Day(), 13, 0, 0, 0, now.Location())
	afternoonEnd := time.Date(now.Year(), now.Month(), now.Day(), 17, 0, 0, 0, now.Location())

	var session string
	if !now.Before(morningStart) && now.Before(morningEnd) {
		session = "morning"
	} else if !now.Before(afternoonStart) && now.Before(afternoonEnd) {
		session = "afternoon"
	} else {
		jsonError(w, "Time in is only allowed during working hours (8AM–12PM or 1PM–5PM)", http.StatusBadRequest)
		return
	}

	// Check if this session already exists for today
	var exists bool
	err := db.QueryRow(`
		SELECT EXISTS(
			SELECT 1 FROM time_logs
			WHERE user_id = $1
			AND log_date = CURRENT_DATE
			AND session = $2
		)
	`, req.UserID, session).Scan(&exists)
	if err != nil {
		jsonError(w, "Database error", http.StatusInternalServerError)
		return
	}
	if exists {
		jsonError(w, "Already timed in for the "+session+" session today", http.StatusConflict)
		return
	}

	// If timing in for afternoon, check if morning session was forgotten (timed in but no time_out)
	// Mark that session as disregarded (hours_rendered = 0, status = 'no_timeout')
	if session == "afternoon" {
		_, err = db.Exec(`
			UPDATE time_logs
			SET hours_rendered = 0,
			    status = 'no_timeout'
			WHERE user_id = $1
			AND log_date = CURRENT_DATE
			AND session = 'morning'
			AND time_out IS NULL
		`, req.UserID)
		if err != nil {
			jsonError(w, "Database error during morning session check", http.StatusInternalServerError)
			return
		}
	}

	// Determine status: late if past 8:15 AM for morning, past 1:15 PM for afternoon
	status := "present"
	graceEnd := morningStart.Add(15 * time.Minute) // 8:15 AM
	if session == "afternoon" {
		graceEnd = afternoonStart.Add(15 * time.Minute) // 1:15 PM
	}
	if now.After(graceEnd) {
		status = "late"
	}

	_, err = db.Exec(`
		INSERT INTO time_logs (user_id, log_date, session, time_in, status)
		VALUES ($1, $2, $3, $4, $5)
	`, req.UserID, now.Format("2006-01-02"), session, now.Format("15:04:05"), status)
	if err != nil {
		jsonError(w, "Failed to record time in", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]string{
		"message": "Time in recorded successfully",
		"session": session,
		"time_in": now.Format("15:04:05"),
		"status":  status,
	})
}
