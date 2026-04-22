package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

func InternTimeLogs(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	userID := r.URL.Query().Get("user_id")
	if userID == "" {
		jsonError(w, "user_id is required", http.StatusBadRequest)
		return
	}

	rows, err := db.Query(`
		SELECT log_date, time_in::text, time_out::text, hours_rendered, status, remarks
		FROM time_logs
		WHERE user_id = $1
		ORDER BY log_date DESC
	`, userID)
	if err != nil {
		jsonError(w, "Failed to fetch logs", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	type LogEntry struct {
		Date       string `json:"date"`
		Day        string `json:"day"`
		TimeIn     string `json:"time_in"`
		TimeOut    string `json:"time_out"`
		TotalHours string `json:"total_hours"`
		Status     string `json:"status"`
		Remarks    string `json:"remarks"`
	}

	var logs []LogEntry
	for rows.Next() {
		var logDate time.Time
		var timeIn, timeOut sql.NullString
		var hoursRendered sql.NullFloat64
		var status, remarks sql.NullString

		if err := rows.Scan(&logDate, &timeIn, &timeOut, &hoursRendered, &status, &remarks); err != nil {
			continue
		}

		months := []string{"January", "February", "March", "April", "May", "June",
			"July", "August", "September", "October", "November", "December"}

		dateStr := fmt.Sprintf("%s %d", months[logDate.Month()-1], logDate.Day())
		dayStr := logDate.Weekday().String()[:3]

		timeInStr := "–"
		if timeIn.Valid && timeIn.String != "" {
			t, err := time.Parse("15:04:05", timeIn.String)
			if err == nil {
				timeInStr = t.Format("3:04 PM") // formats as "10:57 AM"
			}
		}

		timeOutStr := "–"
		if timeOut.Valid && timeOut.String != "" {
			t, err := time.Parse("15:04:05", timeOut.String)
			if err == nil {
				timeOutStr = t.Format("3:04 PM") // ormats as "5:00 PM"
			}
		}

		hoursStr := "–"
		if hoursRendered.Valid && hoursRendered.Float64 > 0 {
			h := int(hoursRendered.Float64)
			m := int((hoursRendered.Float64 - float64(h)) * 60)
			if m == 0 {
				hoursStr = fmt.Sprintf("%dh", h)
			} else {
				hoursStr = fmt.Sprintf("%dh %dm", h, m)
			}
		}

		statusStr := "absent"
		if status.Valid {
			statusStr = status.String
		}
		remarksStr := ""
		if remarks.Valid {
			remarksStr = remarks.String
		}

		logs = append(logs, LogEntry{
			Date:       dateStr,
			Day:        dayStr,
			TimeIn:     timeInStr,
			TimeOut:    timeOutStr,
			TotalHours: hoursStr,
			Status:     statusStr,
			Remarks:    remarksStr,
		})
	}

	if logs == nil {
		logs = []LogEntry{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(logs)
}

func InternTimeLogStats(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	userID := r.URL.Query().Get("user_id")
	if userID == "" {
		jsonError(w, "user_id is required", http.StatusBadRequest)
		return
	}

	var totalHours float64
	db.QueryRow(`
		SELECT COALESCE(SUM(hours_rendered), 0)
		FROM time_logs WHERE user_id = $1
	`, userID).Scan(&totalHours)

	var requiredHours float64
	db.QueryRow(`
		SELECT COALESCE(required_ojt_hours, 0)
		FROM intern_profiles WHERE user_id = $1
	`, userID).Scan(&requiredHours)

	remaining := requiredHours - totalHours
	if remaining < 0 {
		remaining = 0
	}

	var lateArrivals int
	db.QueryRow(`
		SELECT COUNT(*) FROM time_logs
		WHERE user_id = $1 AND status = 'late'
	`, userID).Scan(&lateArrivals)

	var absences int
	db.QueryRow(`
		SELECT COUNT(*) FROM time_logs
		WHERE user_id = $1 AND status = 'absent'
	`, userID).Scan(&absences)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"total_hours":     int(totalHours),
		"remaining_hours": int(remaining),
		"late_arrivals":   lateArrivals,
		"absences":        absences,
	})
}
