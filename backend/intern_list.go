package main

import (
	"encoding/json"
	"net/http"
)

type InternStatus struct {
	UserID    int    `json:"user_id"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Status    string `json:"status"`
}

func DashboardInternList(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	rows, err := db.Query(`
    SELECT 
        u.id,
        u.first_name,
        u.last_name,
        COALESCE(
            (SELECT status FROM time_logs 
             WHERE user_id = u.id 
             AND log_date = CURRENT_DATE 
             ORDER BY time_in DESC 
             LIMIT 1),
            'absent'
        ) AS status
    FROM users u
    WHERE u.role = 'intern'
    ORDER BY u.first_name ASC
`)
	if err != nil {
		jsonError(w, "Error fetching intern list", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var interns []InternStatus
	for rows.Next() {
		var intern InternStatus
		if err := rows.Scan(&intern.UserID, &intern.FirstName, &intern.LastName, &intern.Status); err != nil {
			continue
		}
		interns = append(interns, intern)
	}

	if interns == nil {
		interns = []InternStatus{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(interns)
}
