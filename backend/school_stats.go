package main

import (
	"encoding/json"
	"net/http"
)

// Struct for chart data
type SchoolStat struct {
	Year   int    `json:"year"`
	School string `json:"school"`
	Count  int    `json:"count"`
}

// Handler
func SchoolStats(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	// Query: count interns per school
	rows, err := db.Query(`
		SELECT 
			EXTRACT(YEAR FROM created_at)::int as year,
			school, 
			COUNT(*) as count
		FROM users
		WHERE role = 'intern'
		GROUP BY year, school
		ORDER BY year, school
	`)
	if err != nil {
		jsonError(w, "Error fetching school stats", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var stats []SchoolStat

	for rows.Next() {
		var stat SchoolStat
		err := rows.Scan(&stat.Year, &stat.School, &stat.Count)
		if err != nil {
			jsonError(w, "Error reading data", http.StatusInternalServerError)
			return
		}
		stats = append(stats, stat)
	}

	if stats == nil {
		stats = []SchoolStat{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(stats)
}
