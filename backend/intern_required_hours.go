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

	if req.RequiredHours <= 0 {
		jsonError(w, "Required hours must be greater than 0", http.StatusBadRequest)
		return
	}

	_, err := db.Exec(`
        INSERT INTO intern_profiles (user_id, school, required_ojt_hours)
    SELECT $1, school, $2
    FROM users
    WHERE id = $1
    ON CONFLICT (user_id)
    DO UPDATE SET required_ojt_hours = $2
`, req.UserID, req.RequiredHours)

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
