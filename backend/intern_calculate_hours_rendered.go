package main

import (
	"encoding/json"
	"math"
	"net/http"
	"time"
)

func calculateHoursRendered(timeIn, timeOut time.Time) float64 {
	workStart := time.Date(
		timeIn.Year(),
		timeIn.Month(),
		timeIn.Day(), 8, 0, 0, 0,
		timeIn.Location())

	lunchStart := time.Date(
		timeIn.Year(),
		timeIn.Month(),
		timeIn.Day(), 12, 0, 0, 0,
		timeIn.Location())

	lunchEnd := time.Date(
		timeIn.Year(),
		timeIn.Month(),
		timeIn.Day(), 13, 0, 0, 0,
		timeIn.Location())

	workEnd := time.Date(
		timeIn.Year(),
		timeIn.Month(),
		timeIn.Day(), 17, 0, 0, 0,
		timeIn.Location())

	// Clamp
	if timeIn.Before(workStart) {
		timeIn = workStart
	}
	// If clocked in during lunch, start counting from 1PM
	if !timeIn.Before(lunchStart) && timeIn.Before(lunchEnd) {
		timeIn = lunchEnd
	}
	if timeOut.After(workEnd) {
		timeOut = workEnd
	}

	var totalHours float64

	// Entirely before lunch
	if timeOut.Before(lunchStart) || timeOut.Equal(lunchStart) {
		totalHours = timeOut.Sub(timeIn).Hours()

		// Entirely after lunch
	} else if timeIn.After(lunchEnd) || timeIn.Equal(lunchEnd) {
		totalHours = timeOut.Sub(timeIn).Hours()

		// Spans lunch — this shouldn't happen with sessions, but handled as safety net
	} else {
		morningHours := 0.0
		if timeIn.Before(lunchStart) {
			morningHours = lunchStart.Sub(timeIn).Hours()
		}
		afternoonHours := 0.0
		if timeOut.After(lunchEnd) {
			afternoonHours = timeOut.Sub(lunchEnd).Hours()
		}
		totalHours = morningHours + afternoonHours
	}

	return math.Round(totalHours*100) / 100
}

func InternCalculateHoursRendered(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	timeInStr := r.URL.Query().Get("time_in")
	timeOutStr := r.URL.Query().Get("time_out")

	if timeInStr == "" || timeOutStr == "" {
		jsonError(w, "time_in and time_out are required", http.StatusBadRequest)
		return
	}

	layout := "2006-01-02 15:04"
	timeIn, err1 := time.Parse(layout, timeInStr)
	timeOut, err2 := time.Parse(layout, timeOutStr)
	if err1 != nil || err2 != nil {
		jsonError(w, "Invalid time format. Use YYYY-MM-DD HH:MM", http.StatusBadRequest)
		return
	}
	if timeOut.Before(timeIn) {
		jsonError(w, "time_out cannot be before time_in", http.StatusBadRequest)
		return
	}

	hours := calculateHoursRendered(timeIn, timeOut)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]any{
		"hours_rendered": hours,
	})
}
