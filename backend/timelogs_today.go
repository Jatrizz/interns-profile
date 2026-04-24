package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"time"
)

func TimeLogsToday(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	// Get query params
	now := time.Now()
	month := int(now.Month())
	year := now.Year()

	if monthStr := r.URL.Query().Get("month"); monthStr != "" {
		if m, err := strconv.Atoi(monthStr); err == nil {
			month = m
		}
	}
	if yearStr := r.URL.Query().Get("year"); yearStr != "" {
		if y, err := strconv.Atoi(yearStr); err == nil {
			year = y
		}
	}

	dateStr := r.URL.Query().Get("date")

	startDate := fmt.Sprintf("%d-%02d-01", year, month)
	var endDate string
	if month == 12 {
		endDate = fmt.Sprintf("%d-01-01", year+1)
	} else {
		endDate = fmt.Sprintf("%d-%02d-01", year, month+1)
	}

	var rows *sql.Rows
	var err error

	if dateStr != "" {
		// Filter by exact date
		rows, err = db.Query(`
			SELECT 
				u.first_name,
				u.last_name,
				tl.log_date,
				tl.time_in::text,
				tl.time_out::text,
				tl.hours_rendered,
				COALESCE(tl.status, 'absent') AS status,
				tl.remarks
			FROM users u
			LEFT JOIN time_logs tl 
				ON tl.user_id = u.id 
				AND tl.log_date = $1
			WHERE u.role = 'intern'
			ORDER BY u.first_name ASC
		`, dateStr)
	} else {
		// Filter by month/year
		rows, err = db.Query(`
			SELECT 
				u.first_name,
				u.last_name,
				tl.log_date,
				tl.time_in::text,
				tl.time_out::text,
				tl.hours_rendered,
				COALESCE(tl.status, 'absent') AS status,
				tl.remarks
			FROM users u
			LEFT JOIN time_logs tl 
				ON tl.user_id = u.id 
				AND tl.log_date >= $1
				AND tl.log_date < $2
			WHERE u.role = 'intern'
			ORDER BY u.first_name ASC, tl.log_date DESC
		`, startDate, endDate)
	}

	if err != nil {
		jsonError(w, "Failed to fetch logs", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	type LogEntry struct {
		Name       string `json:"name"`
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
		var firstName, lastName string
		var logDate sql.NullTime
		var timeIn, timeOut sql.NullString
		var hoursRendered sql.NullFloat64
		var status, remarks sql.NullString

		if err := rows.Scan(&firstName, &lastName, &logDate, &timeIn, &timeOut, &hoursRendered, &status, &remarks); err != nil {
			continue
		}

		months := []string{"January", "February", "March", "April", "May", "June",
			"July", "August", "September", "October", "November", "December"}

		dateDisplay := "–"
		dayDisplay := "–"

		if logDate.Valid {
			dateDisplay = fmt.Sprintf("%s %d", months[logDate.Time.Month()-1], logDate.Time.Day())
			dayDisplay = logDate.Time.Weekday().String()[:3]
		}

		timeInStr := "–"
		if timeIn.Valid && timeIn.String != "" {
			if t, err := time.Parse("15:04:05", timeIn.String); err == nil {
				timeInStr = t.Format("3:04 PM")
			}
		}

		timeOutStr := "–"
		if timeOut.Valid && timeOut.String != "" {
			if t, err := time.Parse("15:04:05", timeOut.String); err == nil {
				timeOutStr = t.Format("3:04 PM")
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
			Name:       firstName + " " + lastName,
			Date:       dateDisplay,
			Day:        dayDisplay,
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
