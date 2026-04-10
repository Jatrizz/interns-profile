package main

import (
	"encoding/json"
	"net/http"
)

type InternList struct {
	ID            int    `json:"id"`
	Photo         string `json:"photo"`
	Name          string `json:"name"`
	School        string `json:"school"`
	Program       string `json:"program"`
	CreatedAt     string `json:"created_at"`
}

type DashboardResponse struct {
	TotalInterns int      `json:"total_interns"`
	Interns      []InternList `json:"interns"`
	Username     string   `json:"username"`
}

func Dashboard(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	// Get query parameters
	username := r.URL.Query().Get("username")
	search := r.URL.Query().Get("search")
	sortBy := r.URL.Query().Get("sort_by")
	sortOrder := r.URL.Query().Get("sort_order")

	// Default sort
	if sortBy == "" {
	    sortBy = "created_at"
	}

	// Validate sort_by to prevent SQL injection
	allowedSortFields := map[string]bool{
		"name":       true,
		"school":     true,
		"program":    true,
		"created_at": true,
	}
	if !allowedSortFields[sortBy] {
		sortBy = "created_at"
	}

	// Default sort order
	if sortOrder != "asc" && sortOrder != "desc" {
		sortOrder = "desc"
	}

	// Get total interns count
	var totalInterns int
	err := db.QueryRow("SELECT COUNT(*) FROM interns").Scan(&totalInterns)
	if err != nil {
		http.Error(w, "Error getting total interns", http.StatusInternalServerError)
		return
	}

	// Build query with search and sort
	query := `SELECT id, COALESCE(photo, ''), name, school, program, contact_number, created_at 
			  FROM interns 
			  WHERE name ILIKE $1 OR school ILIKE $1 OR program ILIKE $1
			  ORDER BY ` + sortBy + ` ` + sortOrder

	searchTerm := "%" + search + "%"
	rows, err := db.Query(query, searchTerm)
	if err != nil {
		http.Error(w, "Error getting interns", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var interns []InternList
	for rows.Next() {
		var intern InternList
		err := rows.Scan(
			&intern.ID,
			&intern.Photo,
			&intern.Name,
			&intern.School,
			&intern.Program,
			&intern.CreatedAt,
		)
		if err != nil {
			http.Error(w, "Error reading intern data", http.StatusInternalServerError)
			return
		}
		interns = append(interns, intern)
	}

	if interns == nil {
		interns = []InternList{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(DashboardResponse{
		TotalInterns: totalInterns,
		Interns:      interns,
		Username:     username,
	})
}
