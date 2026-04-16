package main

import (
	"encoding/json"
	"net/http"
	"strconv"
	"time"
)

type DayHours struct {
	Day   string  `json:"day"`
	Hours float64 `json:"hours"`
}

func InternWeeklyHours(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	userIDStr := r.URL.Query().Get("user_id")
	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		jsonError(w, "Invalid user_id", http.StatusBadRequest)
		return
	}

	// Get the Monday of the current week
	now := time.Now()
	weekday := int(now.Weekday())
	if weekday == 0 {
		weekday = 7 // Sunday becomes 7 so Monday offset works
	}
	monday := now.AddDate(0, 0, -(weekday - 1))

	days := []string{"Mon", "Tue", "Wed", "Thu", "Fri"}
	result := make([]DayHours, 5)

	for i := 0; i < 5; i++ {
		date := monday.AddDate(0, 0, i).Format("2006-01-02")
		var hours float64
		err := db.QueryRow(`
            SELECT COALESCE(SUM(hours_rendered), 0)
            FROM time_logs
            WHERE user_id = $1 AND log_date = $2
        `, userID, date).Scan(&hours)
		if err != nil {
			hours = 0
		}
		result[i] = DayHours{Day: days[i], Hours: hours}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}
