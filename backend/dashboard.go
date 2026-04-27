package main

import (
	"encoding/json"
	"net/http"
)

type InternList struct {
	ID        int    `json:"id"`
	IDNumber  string `json:"id_number"`
	Photo     string `json:"photo"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	School    string `json:"school"`
	Program   string `json:"program"`
	CreatedAt string `json:"created_at"`
}

type DashboardResponse struct {
	FirstName    string `json:"first_name"`
	TotalInterns int    `json:"total_interns"`
	NewInterns   int    `json:"new_interns"`
	TotalSchools int    `json:"total_schools"`
}

func Dashboard(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	// Get firstName from query parameters (for welcome message in the dashboard)
	firstName := r.URL.Query().Get("first_name")

	// Get total interns count
	var totalInterns int
	err := db.QueryRow("SELECT COUNT(*) FROM users WHERE role = 'intern'").Scan(&totalInterns)
	if err != nil {
		http.Error(w, "Error getting total users", http.StatusInternalServerError)
		return
	}

	// Get total schools count
	var totalSchools int
	err = db.QueryRow("SELECT COUNT(DISTINCT school) FROM users WHERE role = 'intern'").Scan(&totalSchools)
	if err != nil {
		http.Error(w, "Error getting total schools", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(DashboardResponse{
		FirstName:    firstName,
		TotalInterns: totalInterns,
		NewInterns:   0, // now handled by /new-interns-today
		TotalSchools: totalSchools,
	})
}

// NewInternsToday returns the count of interns added on a specific date.
// Expects a query param: ?date=YYYY-MM-DD
// Example: GET /new-interns-today?date=2025-04-24
func NewInternsToday(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	date := r.URL.Query().Get("date")
	if date == "" {
		http.Error(w, "Missing 'date' query parameter", http.StatusBadRequest)
		return
	}

	var count int
	err := db.QueryRow(`
		SELECT COUNT(*)
		FROM users
		WHERE role = 'intern'
		AND DATE(created_at) = $1
	`, date).Scan(&count)
	if err != nil {
		http.Error(w, "Error getting new interns count", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]int{"count": count})
}

func GetRecentActivity(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	rows, err := db.Query(`
        SELECT 
            CONCAT(u.first_name, ' ', u.last_name) AS name,
            tl.status,
            tl.time_in::text,
            tl.log_date
        FROM time_logs tl
        JOIN users u ON u.id = tl.user_id
        ORDER BY tl.created_at DESC
        LIMIT 5
    `)
	if err != nil {
		jsonError(w, "Failed to fetch recent activity", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	type Activity struct {
		Name    string `json:"name"`
		Status  string `json:"status"`
		TimeIn  string `json:"time_in"`
		LogDate string `json:"log_date"`
	}

	var activities []Activity
	for rows.Next() {
		var a Activity
		var timeIn, status string
		if err := rows.Scan(&a.Name, &status, &timeIn, &a.LogDate); err != nil {
			continue
		}
		a.Status = status
		a.TimeIn = timeIn
		activities = append(activities, a)
	}

	if activities == nil {
		activities = []Activity{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(activities)
}