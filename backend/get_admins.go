package main

import (
	"encoding/json"
	"net/http"
)

// Admin represents a registered admin account
type Admin struct {
	ID       	 int    `json:"id"`
	Username 	 string `json:"username"`
	PhoneNumber  string `json:"phone_number"`
	CreatedAt 	 string `json:"created_at"`
}

// GetAdminsHandler fetches all admins
func GetAdminsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	// Query database
	rows, err := db.Query(`
		SELECT id, username, created_at
		FROM admin
		ORDER BY created_at DESC
	`)
	if err != nil {
		http.Error(w, "Error fetching admins", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var admins []Admin

	for rows.Next() {
		var admin Admin
		err := rows.Scan(&admin.ID, &admin.Username, &admin.CreatedAt)
		if err != nil {
			http.Error(w, "Error reading admin data", http.StatusInternalServerError)
			return
		}
		admins = append(admins, admin)
	}

	if admins == nil {
		admins = []Admin{}
	}

	// Return JSON
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(admins)
}