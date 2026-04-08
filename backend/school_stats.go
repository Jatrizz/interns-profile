package main

import (
	"encoding/json"
	"net/http"
)

// Struct for chart data
type SchoolStat struct {
	School string `json:"school"`
	Count  int    `json:"count"`
}

// Handler
func GetSchoolStats(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	// Query: count interns per school
	rows, err := db.Query(`
		SELECT school, COUNT(*) as count
		FROM interns
		GROUP BY school
		ORDER BY count DESC
	`)
	if err != nil {
		http.Error(w, "Error fetching school stats", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var stats []SchoolStat

	for rows.Next() {
		var stat SchoolStat
		err := rows.Scan(&stat.School, &stat.Count)
		if err != nil {
			http.Error(w, "Error reading data", http.StatusInternalServerError)
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