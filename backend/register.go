package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"

	"golang.org/x/crypto/bcrypt"
)

type User struct {
	ID          int    `json:"id"`
	FirstName   string `json:"first_name"`
	LastName    string `json:"last_name"`
	School      string `json:"school"`
	Program     string `json:"program"`
	Email       string `json:"email"`
	PhoneNumber string `json:"phone_number"`
	Password    string `json:"password"`
	Role        string `json:"role"` // "admin" or "intern"
}

func registerHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	var user User
	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Input validation
	if strings.TrimSpace(user.FirstName) == "" {
		http.Error(w, "First name is required", http.StatusBadRequest)
		return
	}
	if strings.TrimSpace(user.LastName) == "" {
		http.Error(w, "Last name is required", http.StatusBadRequest)
		return
	}
	if strings.TrimSpace(user.School) == "" {
		http.Error(w, "School is required", http.StatusBadRequest)
		return
	}
	if strings.TrimSpace(user.Program) == "" {
		http.Error(w, "Program is required", http.StatusBadRequest)
		return
	}
	if strings.TrimSpace(user.Email) == "" {
		http.Error(w, "Email is required", http.StatusBadRequest)
		return
	}
	if len(user.PhoneNumber) != 11 || !strings.HasPrefix(user.PhoneNumber, "09") {
		http.Error(w, "Invalid phone number", http.StatusBadRequest)
		return
	}
	if strings.TrimSpace(user.Password) == "" {
		http.Error(w, "Password is required", http.StatusBadRequest)
		return
	}
	if len(user.Password) < 6 {
		http.Error(w, "Password must be at least 6 characters", http.StatusBadRequest)
		return
	}

	// Role validation
	user.Role = strings.ToLower(strings.TrimSpace(user.Role))
	if user.Role != "admin" && user.Role != "intern" {
		http.Error(w, "Role must be 'admin' or 'intern'", http.StatusBadRequest)
		return
	}

	// Check for duplicate phone number
	var exists bool
	err = db.QueryRow("SELECT EXISTS(SELECT 1 FROM users WHERE phone_number = $1)",
		user.PhoneNumber).Scan(&exists)
	if err != nil {
		http.Error(w, "Error checking phone number", http.StatusInternalServerError)
		return
	}
	if exists {
		http.Error(w, "Phone number already registered", http.StatusConflict)
		return
	}

	// Hash the password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		http.Error(w, "Error hashing password", http.StatusInternalServerError)
		return
	}

	// Save to database including role
	_, err = db.Exec("INSERT INTO users (first_name, last_name, email, school, program, phone_number, password_hash, role) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)",
		user.FirstName, user.LastName, user.Email, user.School, user.Program, user.PhoneNumber, string(hashedPassword), user.Role)
	if err != nil {
		http.Error(w, "Error saving user", http.StatusInternalServerError)
		return
	}

	fmt.Fprintf(w, "User registered successfully as %s", user.Role)
}
