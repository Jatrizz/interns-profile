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

	var req struct {
		UserID string `json:"user_id"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		jsonError(w, "Invalid body", http.StatusBadRequest)
		return
	}

	now := time.Now()

	earliest := time.Date(now.Year(), now.Month(), now.Day(), 7, 45, 0, 0, now.Location())
	if now.Before(earliest) {
		jsonError(w, "Clock-in should be at least 7:45 AM", http.StatusBadRequest)
		return
	}

	var alreadyClockedIn bool
	err := db.QueryRow(`
		SELECT EXISTS(
			SELECT 1 FROM time_logs
			WHERE user_id = $1
			AND log_date = CURRENT_DATE
			AND time_in IS NOT NULL
		)
	`, req.UserID).Scan(&alreadyClockedIn)
	if err != nil {
		jsonError(w, "DB error", http.StatusInternalServerError)
		return
	}
	if alreadyClockedIn {
		jsonError(w, "Already timed in", http.StatusConflict)
		return
	}

	grace := time.Date(now.Year(), now.Month(), now.Day(), 8, 15, 0, 0, now.Location())

	status := "on-time"
	
	if now.After(grace) {
		status = "late"
	}

	_, err = db.Exec(`
		INSERT INTO time_logs (user_id, log_date, time_in, status)
		VALUES ($1, CURRENT_DATE, $2, $3)
		ON CONFLICT (user_id, log_date)
		DO UPDATE SET
			time_in = EXCLUDED.time_in,
			status  = EXCLUDED.status
	`, req.UserID, now.Format("15:04:05"), status)
	if err != nil {
		jsonError(w, "Failed to record time-in", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]string{
		"message": "Time-in recorded",
		"time_in": now.Format("15:04:05"),
		"status":  status,
	})
}