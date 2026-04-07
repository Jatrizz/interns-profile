package main

import (
	"encoding/json"
	"net/http"
	"path/filepath"
	"regexp"
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
		Email         string `json:"email"`
	}

	var intern InternDetail
	err := json.NewDecoder(r.Body).Decode(&intern)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Allow empty photo but validate extension if present
	if intern.Photo != "" {
		ext := strings.ToLower(filepath.Ext(intern.Photo))
		if ext != ".jpg" && ext != ".jpeg" && ext != ".png" {
			http.Error(w, "Photo must be jpg, jpeg, or png", http.StatusBadRequest)
			return
		}
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

	// Email validation
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	if strings.TrimSpace(intern.Email) == "" || !emailRegex.MatchString(intern.Email) {
		http.Error(w, "Invalid email address", http.StatusBadRequest)
		return
	}

	// Check if email already exists
var exists bool
err = db.QueryRow("SELECT EXISTS(SELECT 1 FROM interns WHERE email = $1)", intern.Email).Scan(&exists)
if err != nil {
	http.Error(w, "Error checking email", http.StatusInternalServerError)
	return
}
if exists {
	http.Error(w, "Email already registered", http.StatusConflict)
	return
}

// Insert intern into database
_, err = db.Exec(`
	INSERT INTO interns (photo, first_name, last_name, program, school, email, contact_number)
	VALUES ($1, $2, $3, $4, $5, $6, $7)
`,
	intern.Photo,
	intern.FirstName,
	intern.LastName,
	intern.Program,
	intern.School,
	intern.Email,
	intern.ContactNumber,
	
)
if err != nil {
	println("DB ERROR:", err.Error())
	http.Error(w, "Error adding intern", http.StatusInternalServerError)
	return
}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "Intern added successfully"})
}