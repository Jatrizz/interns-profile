package main

import (
	"encoding/json"
	"net/http"
)

// for intern dropdown in time logs form
func InternDropdown(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	rows, err := db.Query(`
        SELECT CONCAT(first_name, ' ', last_name) AS full_name
        FROM users
        WHERE role = 'intern'
        ORDER BY first_name ASC
    `)
	if err != nil {
		jsonError(w, "Failed to fetch interns", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var names []string
	for rows.Next() {
		var name string
		if err := rows.Scan(&name); err != nil {
			continue
		}
		names = append(names, name)
	}

	if names == nil {
		names = []string{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(names)
}
