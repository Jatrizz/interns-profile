package main

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"strconv"
)

// Intern struct (make sure this matches your DB)
type InternDetail struct {
	ID            int    `json:"id"`
	Photo         string `json:"photo"`
	Name          string `json:"name"`
	School        string `json:"school"`
	Program       string `json:"program"`
	ContactNumber string `json:"contact_number"`
}

// GetInternHandler handles fetching a single intern
func GetInternHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	// Get ID from query parameter
	// Example: /intern?id=1
	idParam := r.URL.Query().Get("id")
	if idParam == "" {
		http.Error(w, "Intern ID is required", http.StatusBadRequest)
		return
	}

	// Convert string to int
	id, err := strconv.Atoi(idParam)
	if err != nil {
		http.Error(w, "Invalid ID", http.StatusBadRequest)
		return
	}

	var intern InternDetail

	// Query database
	err = db.QueryRow(`
		SELECT id, photo, name, school, program, contact_number
		FROM interns
		WHERE id = $1
	`, id).Scan(
		&intern.ID,
		&intern.Photo,
		&intern.Name,
		&intern.School,
		&intern.Program,
		&intern.ContactNumber,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			http.Error(w, "Intern not found", http.StatusNotFound)
			return
		}
		http.Error(w, "Database error", http.StatusInternalServerError)
		return
	}

	// Return JSON response
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(intern)
}