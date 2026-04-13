package main

import (
	"encoding/json"
	"net/http"
)

// Stats in Frontpage - # (interns, schools, programs)

// Response struct for stats
type StatsResponse struct {
	Interns  int `json:"interns"`
	Schools  int `json:"schools"`
	Programs int `json:"programs"`
}

func GetStats(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	var stats StatsResponse

	// Count interns ONLY
	err := db.QueryRow(`
		SELECT COUNT(*) 
		FROM users 
		WHERE role = 'intern'
	`).Scan(&stats.Interns)
	if err != nil {
		http.Error(w, "Error counting interns", http.StatusInternalServerError)
		return
	}

	// Count unique schools (interns only)
	err = db.QueryRow(`
		SELECT COUNT(DISTINCT school) 
		FROM users 
		WHERE role = 'intern'
	`).Scan(&stats.Schools)
	if err != nil {
		http.Error(w, "Error counting schools", http.StatusInternalServerError)
		return
	}

	// Count unique programs (interns only)
	err = db.QueryRow(`
		SELECT COUNT(DISTINCT program) 
		FROM users 
		WHERE role = 'intern'
	`).Scan(&stats.Programs)
	if err != nil {
		http.Error(w, "Error counting programs", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(stats)
}