package main

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
)

type UpdateUserRequest struct {
	FirstName   string `json:"first_name"`
	LastName    string `json:"last_name"`
	School      string `json:"school"`
	Program     string `json:"program"`
	PhoneNumber string `json:"phone_number"`
}

func UpdateIntern(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPut {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	// 1. Get ID
	idStr := r.URL.Query().Get("id")
	if idStr == "" {
		http.Error(w, "User ID is required", http.StatusBadRequest)
		return
	}

	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid user ID", http.StatusBadRequest)
		return
	}

	// 2. Check if intern exists
	var exists bool
	err = db.QueryRow(`
		SELECT EXISTS(
			SELECT 1 FROM users 
			WHERE id = $1 AND role = 'intern'
		)
	`, id).Scan(&exists)

	if err != nil {
		http.Error(w, "Error checking user", http.StatusInternalServerError)
		return
	}

	if !exists {
		http.Error(w, "Intern not found or not authorized", http.StatusNotFound)
		return
	}

	// 3. Decode request
	var user UpdateUserRequest
	err = json.NewDecoder(r.Body).Decode(&user)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// 4. Validation
	if strings.TrimSpace(user.FirstName) == "" {
		http.Error(w, "First name is required", http.StatusBadRequest)
		return
	}
	if strings.TrimSpace(user.LastName) == "" {
		http.Error(w, "Last name is required", http.StatusBadRequest)
		return
	}
	if strings.TrimSpace(user.School) == "" {
		http.Error(w, "School is required", http.StatusBadRequest)
		return
	}
	if strings.TrimSpace(user.Program) == "" {
		http.Error(w, "Program is required", http.StatusBadRequest)
		return
	}
	if strings.TrimSpace(user.PhoneNumber) == "" {
		http.Error(w, "Phone number is required", http.StatusBadRequest)
		return
	}

	// 5. UPDATE WITHOUT EMAIL
	_, err = db.Exec(`
		UPDATE users 
		SET first_name = $1,
			last_name = $2,
			school = $3,
			program = $4,
			phone_number = $5
		WHERE id = $6
	`,
		user.FirstName,
		user.LastName,
		user.School,
		user.Program,
		user.PhoneNumber,
		id,
	)

	if err != nil {
		http.Error(w, "Error updating intern", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"message": "Intern updated successfully (email locked)",
	})
}