package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

func GetTimeLogsForIntern(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	name := r.URL.Query().Get("name")
	if name == "" {
		jsonError(w, "Name is required", http.StatusBadRequest)
		return
	}

	rows, err := db.Query(`
        SELECT 
            tl.log_date,
            tl.time_in::text,
            tl.time_out::text,
            tl.hours_rendered,
            tl.status,
            tl.remarks
        FROM time_logs tl
        JOIN users u ON u.id = tl.user_id
        WHERE CONCAT(u.first_name, ' ', u.last_name) = $1
        ORDER BY tl.log_date DESC
    `, name)
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
				timeOutStr = t.Format("3:04 PM") // formats as "5:00 PM"
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

// for intern dropdown in time logs form
func InternDropdown(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	rows, err := db.Query(`
        SELECT CONCAT(first_name, ' ', last_name) AS full_name
        FROM users
        WHERE role = 'intern'
        ORDER BY first_name ASC
    `)
	if err != nil {
		jsonError(w, "Failed to fetch interns", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var names []string
	for rows.Next() {
		var name string
		if err := rows.Scan(&name); err != nil {
			continue
		}
		names = append(names, name)
	}

	if names == nil {
		names = []string{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(names)
}
