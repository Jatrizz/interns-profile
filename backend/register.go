package main

import (
	"encoding/json"
	"net/http"
	"strings"

	_ "github.com/lib/pq"
	"golang.org/x/crypto/bcrypt"
)

type User struct {
	ID          int    `json:"id"`
	FirstName   string `json:"first_name"`
	LastName    string `json:"last_name"`
	School      string `json:"school"`
	Program     string `json:"program"`
	Email       string `json:"email"`
	Password    string `json:"password"`
	PhoneNumber string `json:"phone_number"`
}

func registerHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodOptions {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		w.WriteHeader(http.StatusOK)
		return
	}

	if r.Method != http.MethodPost {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")

	var user User
	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		http.Error(w, `{"error":"Invalid request body"}`, http.StatusBadRequest)
		return
	}

	// Validation
	if strings.TrimSpace(user.FirstName) == "" ||
		strings.TrimSpace(user.LastName) == "" ||
		strings.TrimSpace(user.School) == "" ||
		strings.TrimSpace(user.Program) == "" ||
		strings.TrimSpace(user.Email) == "" ||
		strings.TrimSpace(user.Password) == "" {
		http.Error(w, `{"error":"All fields are required"}`, http.StatusBadRequest)
		return
	}

	if !strings.Contains(user.Email, "@") {
		http.Error(w, `{"error":"Invalid email format"}`, http.StatusBadRequest)
		return
	}

	if len(user.Password) < 6 {
		http.Error(w, `{"error":"Password must be at least 6 characters"}`, http.StatusBadRequest)
		return
	}

	// Check duplicate
	var exists bool
	err := db.QueryRow("SELECT EXISTS(SELECT 1 FROM interns WHERE email=$1)", user.Email).Scan(&exists)
	if err != nil {
		http.Error(w, `{"error":"Database error"}`, http.StatusInternalServerError)
		return
	}
	if exists {
		http.Error(w, `{"error":"Email already registered"}`, http.StatusConflict)
		return
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		http.Error(w, `{"error":"Password hashing failed"}`, http.StatusInternalServerError)
		return
	}

	// Insert user
	_, err = db.Exec(`
		INSERT INTO interns (first_name, last_name, school, program, email, password_hash, phone_number)
		VALUES ($1,$2,$3,$4,$5,$6,$7)`,
		user.FirstName, user.LastName, user.School, user.Program,
		user.Email, string(hashedPassword), user.PhoneNumber,
	)
	if err != nil {
		http.Error(w, `{"error":"Failed to save user"}`, http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]string{
		"message": "User registered successfully",
	})
}
