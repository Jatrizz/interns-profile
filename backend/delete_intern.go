package main

import (
	"encoding/json"
	"net/http"
	"strconv"
)

func DeleteIntern(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodDelete {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	// Get student ID from query parameter
	idStr := r.URL.Query().Get("id")
	if idStr == "" {
		http.Error(w, "Student ID is required", http.StatusBadRequest)
		return
	}

	//Convert ID from string to integer
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid student ID", http.StatusBadRequest)
		return
	}

	// Check if student exists
	var exists bool
	err = db.QueryRow("SELECT EXISTS(SELECT 1 FROM interns WHERE id = $1)", id).Scan(&exists)
	if err != nil {
		http.Error(w, "Error checking student existence", http.StatusInternalServerError)
		return
	}
	if !exists {
		http.Error(w, "Intern not found", http.StatusNotFound)
		return
	}

	// Delete student from database
	result, err := db.Exec("DELETE FROM interns WHERE id = $1", id)
	if err != nil {
		http.Error(w, "Error deleting intern", http.StatusInternalServerError)
		return
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		http.Error(w, "Error checking deletion result", http.StatusInternalServerError)
		return
	}
	if rowsAffected == 0 {
		http.Error(w, "Intern not found", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "Intern deleted successfully"})
}
