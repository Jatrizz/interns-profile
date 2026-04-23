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
		UserID string `json:"user_id"`
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

	// Check if already timed in today
	var exists bool
	err := db.QueryRow(`
		SELECT EXISTS(
			SELECT 1 FROM time_logs
			WHERE user_id = $1
			AND log_date = CURRENT_DATE
		)
	`, req.UserID).Scan(&exists)
	if err != nil {
		jsonError(w, "Database error", http.StatusInternalServerError)
		return
	}
	if exists {
		jsonError(w, "Already timed in for today", http.StatusConflict)
		return
	}

	// Determine status: late if past 8:15 AM
	status := "on-time"
	graceEnd := time.Date(now.Year(), now.Month(), now.Day(), 8, 15, 0, 0, now.Location())
	if now.After(graceEnd) {
		status = "late"
	}

	_, err = db.Exec(`
		INSERT INTO time_logs (user_id, log_date, time_in, status)
		VALUES ($1, $2, $3, $4)
	`, req.UserID, now.Format("2006-01-02"), now.Format("15:04:05"), status)
	if err != nil {
		jsonError(w, "Failed to record time in", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]string{
		"message": "Time in recorded successfully",
		"time_in": now.Format("15:04:05"),
		"status":  status,
	})
}
