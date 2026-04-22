package main

import (
	"database/sql"
	"encoding/json"
	"net/http"
)

type InternDashboardResponse struct {
	FirstName          string  `json:"first_name"`
	TotalHoursRendered float64 `json:"total_hours_rendered"`
	RemainingHours     float64 `json:"remaining_hours"`
	RequiredOjtHours   float64 `json:"required_ojt_hours"`
	TodaysStatus       string  `json:"todays_status"`
	IsClockedIn        bool    `json:"is_clocked_in"`
	ClockInTime        string  `json:"clock_in_time"`
}

func InternDashboard(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	userID := r.URL.Query().Get("user_id")
	firstName := r.URL.Query().Get("first_name")

	if userID == "" {
		jsonError(w, "user_id is required", http.StatusBadRequest)
		return
	}

	// Total hours rendered
	var totalHours float64
	err := db.QueryRow(`
        SELECT COALESCE(SUM(hours_rendered), 0)
        FROM time_logs
        WHERE user_id = $1
    `, userID).Scan(&totalHours)
	if err != nil {
		jsonError(w, "Error getting total hours", http.StatusInternalServerError)
		return
	}

	// Required hours from intern_profiles
	var requiredHours float64
	err = db.QueryRow(`
        SELECT required_ojt_hours FROM intern_profiles WHERE user_id = $1
    `, userID).Scan(&requiredHours)
	if err == sql.ErrNoRows {
		requiredHours = 0
	} else if err != nil {
		jsonError(w, "Error getting required hours", http.StatusInternalServerError)
		return
	}

	remainingHours := requiredHours - totalHours
	if remainingHours < 0 {
		remainingHours = 0
	}

	// Today's status
	var todaysStatus string
	var isClockedIn bool
	var clockInTime string
	err = db.QueryRow(`
    SELECT status, time_in::text, (time_out IS NULL) AS is_clocked_in
    FROM time_logs
    WHERE user_id = $1 AND log_date = CURRENT_DATE
`, userID).Scan(&todaysStatus, &clockInTime, &isClockedIn)
	if err != nil {
		todaysStatus = "absent"
		isClockedIn = false
		clockInTime = ""
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(InternDashboardResponse{
		FirstName:          firstName,
		TotalHoursRendered: totalHours,
		RemainingHours:     remainingHours,
		RequiredOjtHours:   requiredHours,
		TodaysStatus:       todaysStatus,
		IsClockedIn:        isClockedIn,
		ClockInTime:        clockInTime,
	})
}
