package main

import (
	"encoding/json"
	"net/http"
)

func RestoreIntern(w http.ResponseWriter, r *http.Request) {
	internID := r.URL.Query().Get("id")
	if internID == "" {
		http.Error(w, "Missing intern ID", http.StatusBadRequest)
		return
	}

	// Verify the target user exists and is actually an intern
	var exists bool
	err := db.QueryRow(`
		SELECT EXISTS (
			SELECT 1 FROM users
			WHERE id = $1 AND role = 'intern'
		)
	`, internID).Scan(&exists)
	if err != nil {
		http.Error(w, "Database error", http.StatusInternalServerError)
		return
	}
	if !exists {
		http.Error(w, "Intern not found", http.StatusNotFound)
		return
	}

	// Check if already active to avoid redundant writes
	var isArchived bool
	err = db.QueryRow(`
		SELECT archived FROM users WHERE id = $1
	`, internID).Scan(&isArchived)
	if err != nil {
		http.Error(w, "Database error", http.StatusInternalServerError)
		return
	}
	if !isArchived {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusConflict)
		json.NewEncoder(w).Encode(map[string]string{
			"message": "Intern is already active",
		})
		return
	}

	// Perform the restore
	result, err := db.Exec(`
		UPDATE users
		SET archived = FALSE
		WHERE id = $1 AND role = 'intern'
	`, internID)
	if err != nil {
		http.Error(w, "Failed to restore intern", http.StatusInternalServerError)
		return
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil || rowsAffected == 0 {
		http.Error(w, "Intern not found or already active", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"message": "Intern restored successfully",
	})
}