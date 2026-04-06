package main

import (
	"encoding/json"
	"net/http"
	"strings"
)

func AddIntern(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	type InternDetail struct {
	Photo         string `json:"photo"`
	FirstName     string `json:"first_name"`
	LastName      string `json:"last_name"`
	School        string `json:"school"`
	Program       string `json:"program"`
	ContactNumber string `json:"contact_number"`
	}

	var intern InternDetail
	err := json.NewDecoder(r.Body).Decode(&intern)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Input validation
	if strings.TrimSpace(intern.FirstName) == "" {
		http.Error(w, "First name is required", http.StatusBadRequest)
		return
	}

	if strings.TrimSpace(intern.LastName) == "" {
		http.Error(w, "Last name is required", http.StatusBadRequest)
		return
	}

	if strings.TrimSpace(intern.School) == "" {
		http.Error(w, "School is required", http.StatusBadRequest)
		return
	}

	if strings.TrimSpace(intern.Program) == "" {
		http.Error(w, "Program is required", http.StatusBadRequest)
		return
	}

	if strings.TrimSpace(intern.ContactNumber) == "" {
		http.Error(w, "Contact number is required", http.StatusBadRequest)
		return
	}

	if len(intern.ContactNumber) != 11 || !strings.HasPrefix(intern.ContactNumber, "09") {
		http.Error(w, "Invalid contact number", http.StatusBadRequest)
		return
	}

	// Insert intern into database (FIXED placeholders)
	_, err = db.Exec(`
		INSERT INTO interns (photo, first_name, last_name, school, program, contact_number)
		VALUES ($1, $2, $3, $4, $5, $6)
	`,
		intern.Photo,
		intern.FirstName,
		intern.LastName,
		intern.School,
		intern.Program,
		intern.ContactNumber,
	)

	if err != nil {
		http.Error(w, "Error adding intern", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "Intern added successfully"})
}
