package main

import (
	"encoding/json"
	"net/http"
)

func GetInternsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	rows, err := db.Query(`
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
		WHERE role = 'intern'
		ORDER BY first_name ASC
	`)
	if err != nil {
		http.Error(w, "Database error", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var interns []InternResponse

	for rows.Next() {
		var intern InternDetail

		if err := rows.Scan(
			&intern.IDNumber,
			&intern.Photo,
			&intern.FirstName,
			&intern.LastName,
			&intern.School,
			&intern.Program,
			&intern.Email,
			&intern.PhoneNumber,
			&intern.Resume,
		); err != nil {
			http.Error(w, "Failed to read intern data", http.StatusInternalServerError)
			return
		}

		interns = append(interns, InternResponse{
			IDNumber:    intern.IDNumber,
			Photo:       safeString(intern.Photo),
			FirstName:   intern.FirstName,
			LastName:    intern.LastName,
			School:      intern.School,
			Program:     intern.Program,
			Email:       intern.Email,
			PhoneNumber: intern.PhoneNumber,
			Resume:      safeString(intern.Resume),
		})
	}

	// Return empty array instead of null when no interns exist
	if interns == nil {
		interns = []InternResponse{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(interns)
}