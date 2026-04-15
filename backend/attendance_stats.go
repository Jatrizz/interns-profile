package main

import (
	"database/sql"
	"encoding/json"
	"net/http"
)

// ======================
// RESPONSE STRUCT
// ======================

type AttendanceStats struct {
	TotalInterns int `json:"total_interns"`
	PresentToday int `json:"present_today"`
	LateToday    int `json:"late_today"`
	AbsentToday  int `json:"absent_today"`
}

// ======================
// ERROR HELPER
// ======================

func writeJSONError(w http.ResponseWriter, message string, code int) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	json.NewEncoder(w).Encode(map[string]string{
		"error": message,
	})
}

// ======================
// HANDLER
// ======================

func HandleAttendanceStats(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		var stats AttendanceStats

		query := `
			WITH today_attendance AS (
				SELECT intern_id, status
				FROM attendance
				WHERE date = CURRENT_DATE
			)
			SELECT
				(SELECT COUNT(*) FROM users WHERE role = 'intern'),
				(SELECT COUNT(*) 
				 FROM today_attendance 
				 WHERE status IN ('present','late')
				),
				(SELECT COUNT(*) 
				 FROM today_attendance 
				 WHERE status = 'late'
				),
				(
					(SELECT COUNT(*) FROM users WHERE role = 'intern')
					-
					(SELECT COUNT(*) FROM today_attendance)
				)
		`

		err := db.QueryRow(query).Scan(
			&stats.TotalInterns,
			&stats.PresentToday,
			&stats.LateToday,
			&stats.AbsentToday,
		)

		if err != nil {
			writeJSONError(w, "Failed to fetch stats: "+err.Error(), http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(stats)
	}
}