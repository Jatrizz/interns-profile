package main

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"strconv"
)

// DB struct (raw scan result)
type InternDetail struct {
	IDNumber    string
	Photo       sql.NullString
	FirstName   string
	LastName    string
	School      string
	Program     string
	Email       string
	PhoneNumber string
	Resume      sql.NullString
}

// Response struct (controls JSON order)
type InternResponse struct {
	IDNumber    string `json:"id_number"`
	Photo       string `json:"photo"`
	FirstName   string `json:"first_name"`
	LastName    string `json:"last_name"`
	School      string `json:"school"`
	Program     string `json:"program"`
	Email       string `json:"email"`
	PhoneNumber string `json:"phone_number"`
	Resume      string `json:"resume"`
}

// NULL-safe helper
func safeString(ns sql.NullString) string {
	if ns.Valid {
		return ns.String
	}
	return ""
}

func GetInternHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	// Get ID
	idParam := r.URL.Query().Get("id")
	if idParam == "" {
		http.Error(w, "Intern ID is required", http.StatusBadRequest)
		return
	}

	// Convert ID
	id, err := strconv.Atoi(idParam)
	if err != nil {
		http.Error(w, "Invalid ID", http.StatusBadRequest)
		return
	}

	var intern InternDetail

	// Query users table (ONLY interns)
	err = db.QueryRow(`
		SELECT 
			id_number,
			photo,
			first_name,
			last_name,
			school,
			program,
			email,
			phone_number,
			resume
		FROM users
		WHERE id = $1 AND role = 'intern'
	`, id).Scan(
		&intern.IDNumber,
		&intern.Photo,
		&intern.FirstName,
		&intern.LastName,
		&intern.School,
		&intern.Program,
		&intern.Email,
		&intern.PhoneNumber,
		&intern.Resume,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			http.Error(w, "Intern not found", http.StatusNotFound)
			return
		}

		println("DB ERROR:", err.Error())
		http.Error(w, "Database error", http.StatusInternalServerError)
		return
	}

	// Response (ordered output)
	response := InternResponse{
		IDNumber:    intern.IDNumber,
		Photo:       safeString(intern.Photo),
		FirstName:   intern.FirstName,
		LastName:    intern.LastName,
		School:      intern.School,
		Program:     intern.Program,
		Email:       intern.Email,
		PhoneNumber: intern.PhoneNumber,
		Resume:      safeString(intern.Resume),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}