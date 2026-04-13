package main

import (
	"encoding/json"
	"net/http"
)

type Admin struct {
	ID        int    `json:"id"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Email     string `json:"email"`
	CreatedAt string `json:"created_at"`
}

func GetAdminsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		jsonError(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	rows, err := db.Query(`
		SELECT id, first_name, last_name, email, created_at
		FROM users
		WHERE role = 'admin'
		ORDER BY created_at DESC
	`)
	if err != nil {
		jsonError(w, "Error fetching admins: "+err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var admins []Admin
	for rows.Next() {
		var admin Admin
		err := rows.Scan(&admin.ID, &admin.FirstName, &admin.LastName, &admin.Email, &admin.CreatedAt)
		if err != nil {
			jsonError(w, "Error reading admin data: "+err.Error(), http.StatusInternalServerError)
			return
		}
		admins = append(admins, admin)
	}

	if admins == nil {
		admins = []Admin{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(admins)
}
