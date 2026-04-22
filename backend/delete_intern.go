package main

import (
	"encoding/json"
	"net/http"
	"log/slog"
)

func DeleteIntern(w http.ResponseWriter, r *http.Request) {
	// =========================
	// METHOD CHECK
	// =========================
	if r.Method != http.MethodDelete {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	// =========================
	// GET id_number FROM QUERY
	// =========================
	idNumber := r.URL.Query().Get("id")
	if idNumber == "" {
		http.Error(w, "id_number is required", http.StatusBadRequest)
		return
	}

	// =========================
	// CHECK IF INTERN EXISTS
	// =========================
	var exists bool
	err := db.QueryRow(`
		SELECT EXISTS(
			SELECT 1 FROM users
			WHERE id_number = $1 AND role = 'intern'
		)
	`, idNumber).Scan(&exists)

	if err != nil {
		slog.Error("database error while checking intern",
			"error", err,
			"id_number", idNumber,
		)
		http.Error(w, "Database error", http.StatusInternalServerError)
		return
	}

	if !exists {
		slog.Warn("intern not found",
			"id_number", idNumber,
		)
		http.Error(w, "Intern not found", http.StatusNotFound)
		return
	}

	// =========================
	// DELETE INTERN
	// =========================
	result, err := db.Exec(`
		DELETE FROM users
		WHERE id_number = $1 AND role = 'intern'
	`, idNumber)

	if err != nil {
		slog.Error("failed to delete intern",
			"error", err,
			"id_number", idNumber,
		)
		http.Error(w, "Failed to delete intern", http.StatusInternalServerError)
		return
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		http.Error(w, "Intern not found", http.StatusNotFound)
		return
	}

	// =========================
	// RESPONSE
	// =========================
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"message":   "Intern deleted successfully",
		"id_number": idNumber,
	})
}