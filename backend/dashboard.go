package main

import (
	"encoding/json"
	"net/http"
)

type Intern struct {
	ID            int    `json:"id"`
	Photo         string `json:"photo"`
	Name          string `json:"name"`
	School        string `json:"school"`
	Program       string `json:"program"`
	ContactNumber string `json:"contact_number"`
	CreatedAt     string `json:"created_at"`
}

type DashboardResponse struct {
	TotalInterns int      `json:"total_interns"`
	Interns      []Intern `json:"interns"`
	Username     string   `json:"username"`
}

func Dashboard(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	// Get username from query parameter
	username := r.URL.Query().Get("username")

	// Get total interns count
	var totalInterns int
	err := db.QueryRow("SELECT COUNT(*) FROM interns").Scan(&totalInterns)
	if err != nil {
		http.Error(w, "Error getting total interns", http.StatusInternalServerError)
		return
	}

	// Get all interns
	rows, err := db.Query("SELECT id, COALESCE(photo, ''), name, school, program, contact_number, created_at FROM interns ORDER BY created_at DESC")
	if err != nil {
		http.Error(w, "Error getting interns", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var interns []Intern
	for rows.Next() {
		var intern Intern
		err := rows.Scan(
			&intern.ID,
			&intern.Photo,
			&intern.Name,
			&intern.School,
			&intern.Program,
			&intern.ContactNumber,
			&intern.CreatedAt,
		)
		if err != nil {
			http.Error(w, "Error reading intern data", http.StatusInternalServerError)
			return
		}
		interns = append(interns, intern)
	}

	// Return empty array instead of null if no interns
	if interns == nil {
		interns = []Intern{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(DashboardResponse{
		TotalInterns: totalInterns,
		Interns:      interns,
		Username:     username,
	})
}
