package main

import (
	"encoding/json"
	"net/http"
)

type InternList struct {
	ID        int    `json:"id"`
	IDNumber  string `json:"id_number"`
	Photo     string `json:"photo"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	School    string `json:"school"`
	Program   string `json:"program"`
	CreatedAt string `json:"created_at"`
}

type DashboardResponse struct {
	FirstName    string `json:"first_name"`
	TotalInterns int    `json:"total_interns"`
	NewInterns   int    `json:"new_interns"`
	TotalSchools int    `json:"total_schools"`
}

func Dashboard(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	// Get firstName from query parameters (for welcome message in the dashboard)
	firstName := r.URL.Query().Get("first_name")

	// Get total interns count
	// Shows the Total Number of Interns in the Dashboard
	var totalInterns int
	err := db.QueryRow("SELECT COUNT(*) FROM users").Scan(&totalInterns)
	if err != nil {
		http.Error(w, "Error getting total users", http.StatusInternalServerError)
		return
	}

	// Get new interns this month
	// Shown as "No. of New Interns: 3" on dashboard
	var newInterns int
	err = db.QueryRow(`SELECT COUNT(*) FROM users 
		WHERE EXTRACT(MONTH FROM created_at) = EXTRACT(MONTH FROM CURRENT_DATE)
		AND EXTRACT(YEAR FROM created_at) = EXTRACT(YEAR FROM CURRENT_DATE)`).Scan(&newInterns)
	if err != nil {
		http.Error(w, "Error getting new users", http.StatusInternalServerError)
		return
	}

	// Get total schools count
	var totalSchools int
	err = db.QueryRow("SELECT COUNT(DISTINCT school) FROM users").Scan(&totalSchools)
	if err != nil {
		http.Error(w, "Error getting total schools", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(DashboardResponse{
		FirstName:    firstName,
		TotalInterns: totalInterns,
		NewInterns:   newInterns,
		TotalSchools: totalSchools,
	})
}
