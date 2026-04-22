package main

import (
	"encoding/json"
	"net/http"
)

func InternRequiredHours(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		UserID        string  `json:"user_id"`
		RequiredHours float64 `json:"required_hours"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		jsonError(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if req.UserID == "" {
		jsonError(w, "user_id is required", http.StatusBadRequest)
		return
	}

	if req.RequiredHours <= 0 {
		jsonError(w, "Required hours must be greater than 0", http.StatusBadRequest)
		return
	}

	// First get the school from users table
	var school string
	err := db.QueryRow(`
		SELECT COALESCE(school, '') FROM users WHERE id = $1
	`, req.UserID).Scan(&school)
	if err != nil {
		jsonError(w, "User not found", http.StatusNotFound)
		return
	}

	// Then insert or update intern_profiles
	_, err = db.Exec(`
		INSERT INTO intern_profiles (user_id, school, required_ojt_hours)
		VALUES ($1, $2, $3)
		ON CONFLICT (user_id)
		DO UPDATE SET required_ojt_hours = $3
	`, req.UserID, school, req.RequiredHours)
	if err != nil {
		jsonError(w, "Failed to update required hours", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"message":        "Required hours updated",
		"required_hours": req.RequiredHours,
	})
}
