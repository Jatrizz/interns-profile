package main

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
)

func Updatestudent(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPut {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	// Get intern ID from query parameter
	idStr := r.URL.Query().Get("id")
	if idStr == "" {
		http.Error(w, "Intern ID is required", http.StatusBadRequest)
		return
	}

	// Convert ID from string to int
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid intern ID", http.StatusBadRequest)
		return
	}

	// Check if intern exists
	var exists bool
	err = db.QueryRow("SELECT EXISTS(SELECT 1 FROM interns WHERE id = $1)", id).Scan(&exists)
	if err != nil {
		http.Error(w, "Error checking intern", http.StatusInternalServerError)
		return
	}
	if !exists {
		http.Error(w, "Intern not found", http.StatusNotFound)
		return
	}

	// Decode request body
	var intern Intern
	err = json.NewDecoder(r.Body).Decode(&intern)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Input validation
	if strings.TrimSpace(intern.IDNumber) == "" {
		http.Error(w, "ID number is required", http.StatusBadRequest)
		return
	}
	if strings.TrimSpace(intern.FirstName) == "" {
		http.Error(w, "Name is required", http.StatusBadRequest)
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
	if strings.TrimSpace(intern.Email) == "" {
		http.Error(w, "Email is required", http.StatusBadRequest)
		return
	}
	if strings.TrimSpace(intern.ContactNumber) == "" {
		http.Error(w, "Contact number is required", http.StatusBadRequest)
		return
	}
	if len(intern.ContactNumber) != 11 || !strings.HasPrefix(intern.ContactNumber, "09") {
		http.Error(w, "Invalid contact number - must start with 09 and be 11 digits", http.StatusBadRequest)
		return
	}

	// Update in database
	_, err = db.Exec("UPDATE interns SET id_number=$1, first_name=$2, last_name=$3, school=$4, program=$5, email=$6, contact_number=$7, photo=$8 WHERE id=$9",
		intern.IDNumber, intern.FirstName, intern.LastName, intern.School, intern.Program, intern.Email, intern.ContactNumber, intern.Photo, id)
	if err != nil {
		http.Error(w, "Error updating intern", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"message": "Intern updated successfully",
	})
}
