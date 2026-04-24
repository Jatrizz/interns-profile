package main

import (
	"encoding/json"
	"net/http"
)

func TimeLogsOverview(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	// Total interns
	var totalInterns int
	db.QueryRow(`
		SELECT COUNT(*) FROM users WHERE role = 'intern'
	`).Scan(&totalInterns)

	// Present today (present + late)
	var presentToday int
	db.QueryRow(`
		SELECT COUNT(DISTINCT user_id) FROM time_logs
		WHERE log_date = CURRENT_DATE
		AND status IN ('present', 'late')
	`).Scan(&presentToday)

	// Late today
	var lateToday int
	db.QueryRow(`
		SELECT COUNT(DISTINCT user_id) FROM time_logs
		WHERE log_date = CURRENT_DATE
		AND status = 'late'
	`).Scan(&lateToday)

	// Absent today:
	// 1. Interns with an explicit 'absent' status log for today, OR
	// 2. Interns with no log entry at all for today
	var absentToday int
	db.QueryRow(`
		SELECT COUNT(*) FROM users
		WHERE role = 'intern'
		AND (
			id IN (
				SELECT DISTINCT user_id FROM time_logs
				WHERE log_date = CURRENT_DATE
				AND status = 'absent'
			)
			OR id NOT IN (
				SELECT DISTINCT user_id FROM time_logs
				WHERE log_date = CURRENT_DATE
			)
		)
	`).Scan(&absentToday)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]int{
		"total_interns": totalInterns,
		"present_today": presentToday,
		"late_today":    lateToday,
		"absent_today":  absentToday,
	})
}