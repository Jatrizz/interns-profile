package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"time"
)

// capDailyHours calculates actual worked hours given time_in and time_out,
// clamped to 8:00 AM - 5:00 PM, excluding 12:00 PM - 1:00 PM lunch break.
// Maximum returnable value is 8.0 hours.
func capDailyHours(timeIn, timeOut string) float64 {
	layout := "15:04:05"

	in, err := time.Parse(layout, timeIn)
	if err != nil {
		return 0
	}
	out, err := time.Parse(layout, timeOut)
	if err != nil {
		return 0
	}

	workStart, _ := time.Parse(layout, "08:00:00")
	workEnd, _ := time.Parse(layout, "17:00:00")
	lunchStart, _ := time.Parse(layout, "12:00:00")
	lunchEnd, _ := time.Parse(layout, "13:00:00")

	if in.Before(workStart) {
		in = workStart
	}
	if out.After(workEnd) {
		out = workEnd
	}
	if out.Before(in) {
		return 0
	}

	total := out.Sub(in).Hours()

	lunchOverlapStart := in
	lunchOverlapEnd := out
	if lunchOverlapStart.Before(lunchStart) {
		lunchOverlapStart = lunchStart
	}
	if lunchOverlapEnd.After(lunchEnd) {
		lunchOverlapEnd = lunchEnd
	}
	if lunchOverlapEnd.After(lunchOverlapStart) {
		total -= lunchOverlapEnd.Sub(lunchOverlapStart).Hours()
	}

	if total > 8.0 {
		total = 8.0
	}
	if total < 0 {
		total = 0
	}

	return total
}

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

	dateStr := r.URL.Query().Get("date")

	var rows *sql.Rows
	var err error

	if dateStr != "" {
		rows, err = db.Query(`
			SELECT log_date, time_in::text, time_out::text, status, remarks
			FROM time_logs
			WHERE user_id = $1
			AND log_date = $2
			ORDER BY log_date DESC
		`, userID, dateStr)
	} else {
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

		startDate := fmt.Sprintf("%d-%02d-01", year, month)
		var endDate string
		if month == 12 {
			endDate = fmt.Sprintf("%d-01-01", year+1)
		} else {
			endDate = fmt.Sprintf("%d-%02d-01", year, month+1)
		}

		rows, err = db.Query(`
			SELECT log_date, time_in::text, time_out::text, status, remarks
			FROM time_logs
			WHERE user_id = $1
			AND log_date >= $2
			AND log_date < $3
			ORDER BY log_date DESC
		`, userID, startDate, endDate)
	}

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

	months := []string{"January", "February", "March", "April", "May", "June",
		"July", "August", "September", "October", "November", "December"}

	var logs []LogEntry
	for rows.Next() {
		var logDate time.Time
		var timeIn, timeOut sql.NullString
		var status, remarks sql.NullString

		if err := rows.Scan(&logDate, &timeIn, &timeOut, &status, &remarks); err != nil {
			continue
		}

		dateLabel := fmt.Sprintf("%s %d", months[logDate.Month()-1], logDate.Day())
		dayStr := logDate.Weekday().String()[:3]

		timeInStr := "–"
		if timeIn.Valid && timeIn.String != "" {
			t, err := time.Parse("15:04:05", timeIn.String)
			if err == nil {
				timeInStr = t.Format("3:04 PM")
			}
		}

		timeOutStr := "–"
		if timeOut.Valid && timeOut.String != "" {
			t, err := time.Parse("15:04:05", timeOut.String)
			if err == nil {
				timeOutStr = t.Format("3:04 PM")
			}
		}

		// Compute capped hours from time_in/time_out
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

		statusStr := "absent"
		if status.Valid {
			statusStr = status.String
		}
		remarksStr := ""
		if remarks.Valid {
			remarksStr = remarks.String
		}

		logs = append(logs, LogEntry{
			Date:       dateLabel,
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

	// Fetch all rows with time_in and time_out to compute capped hours per day in Go
	rows, err := db.Query(`
		SELECT log_date, time_in::text, time_out::text
		FROM time_logs
		WHERE user_id = $1
		ORDER BY log_date DESC
	`, userID)
	if err != nil {
		jsonError(w, "Failed to fetch logs", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	months := []string{"January", "February", "March", "April", "May", "June",
		"July", "August", "September", "October", "November", "December"}

	type DailyHours struct {
		Date       string  `json:"date"`
		Day        string  `json:"day"`
		TotalHours float64 `json:"total_hours"`
	}

	// Use a map to accumulate hours per day (each day capped at 8h)
	dailyMap := make(map[string]*DailyHours)
	var dateOrder []string

	for rows.Next() {
		var logDate time.Time
		var timeIn, timeOut sql.NullString

		if err := rows.Scan(&logDate, &timeIn, &timeOut); err != nil {
			continue
		}

		dateKey := logDate.Format("2006-01-02")

		if _, exists := dailyMap[dateKey]; !exists {
			dateLabel := fmt.Sprintf("%s %d", months[logDate.Month()-1], logDate.Day())
			dayStr := logDate.Weekday().String()[:3]
			dailyMap[dateKey] = &DailyHours{
				Date:       dateLabel,
				Day:        dayStr,
				TotalHours: 0,
			}
			dateOrder = append(dateOrder, dateKey)
		}

		if timeIn.Valid && timeIn.String != "" && timeOut.Valid && timeOut.String != "" {
			capped := capDailyHours(timeIn.String, timeOut.String)
			dailyMap[dateKey].TotalHours += capped
			// Hard cap per day at 8 hours
			if dailyMap[dateKey].TotalHours > 8.0 {
				dailyMap[dateKey].TotalHours = 8.0
			}
		}
	}

	// Build ordered slice and sum overall total
	var dailyHours []DailyHours
	var totalHours float64
	for _, key := range dateOrder {
		entry := dailyMap[key]
		dailyHours = append(dailyHours, *entry)
		totalHours += entry.TotalHours
	}

	if dailyHours == nil {
		dailyHours = []DailyHours{}
	}

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
		"daily_hours":     dailyHours,
	})
}