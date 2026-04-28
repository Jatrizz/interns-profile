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
			rows, err = db.Query(`
				SELECT 
					u.first_name,
					u.last_name,
					$1::date AS log_date,
					tl.time_in::text,
					tl.time_out::text,
					CASE
						WHEN EXTRACT(DOW FROM $1::date) IN (0, 6) THEN 'weekend'
						WHEN tl.status IS NOT NULL THEN tl.status
						WHEN $1::date > CURRENT_DATE THEN NULL
						WHEN $1::date < (
							SELECT MIN(tl2.log_date)
							FROM time_logs tl2
							WHERE tl2.user_id = u.id
							AND tl2.time_in IS NOT NULL
						) THEN NULL
						ELSE 'absent'
					END AS status,
					tl.remarks
				FROM users u
				LEFT JOIN time_logs tl 
					ON tl.user_id = u.id 
					AND tl.log_date = $1
					AND tl.time_in IS NOT NULL
				WHERE u.role = 'intern'
				AND u.created_at::date <= $1::date
				ORDER BY u.first_name ASC
			`, dateStr)
		} else {
			rows, err = db.Query(`
				WITH date_series AS (
					SELECT generate_series($1::date, $2::date - INTERVAL '1 day', '1 day')::date AS log_date
				)
				SELECT
					u.first_name,
					u.last_name,
					ds.log_date,
					tl.time_in::text,
					tl.time_out::text,
					CASE
						WHEN tl.status IS NOT NULL THEN tl.status
						WHEN ds.log_date > CURRENT_DATE THEN NULL
						ELSE 'absent'
					END AS status,
					tl.remarks
				FROM users u
				CROSS JOIN date_series ds
				LEFT JOIN time_logs tl
					ON tl.user_id = u.id
					AND tl.log_date = ds.log_date
					AND tl.time_in IS NOT NULL
				WHERE u.role = 'intern'
				AND EXTRACT(DOW FROM ds.log_date) NOT IN (0, 6)
				AND ds.log_date <= CURRENT_DATE
				AND ds.log_date >= u.created_at::date
				ORDER BY ds.log_date DESC, u.first_name ASC
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

	months := []string{"January", "February", "March", "April", "May", "June",
		"July", "August", "September", "October", "November", "December"}

	var logs []LogEntry

	for rows.Next() {
		var firstName, lastName string
		var logDate sql.NullTime
		var timeIn, timeOut sql.NullString
		var status, remarks sql.NullString

		if err := rows.Scan(&firstName, &lastName, &logDate, &timeIn, &timeOut, &status, &remarks); err != nil {
			continue
		}

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

		// Compute capped hours for this specific day only from time_in/time_out
		hoursStr := "–"
		if timeIn.Valid && timeIn.String != "" && timeOut.Valid && timeOut.String != "" {
			capped := capDailyHours(timeIn.String, timeOut.String)
			if capped > 0 {
				h := int(capped)
				m := int((capped - float64(h)) * 60)
				if m == 0 {
					hoursStr = fmt.Sprintf("%dh", h)
				} else {
					hoursStr = fmt.Sprintf("%dh %dm", h, m)
				}
			}
		}

		statusStr := ""
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