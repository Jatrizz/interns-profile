package main

import (
	"encoding/json"
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
	Password    string `json:"password"`
	PhoneNumber string `json:"phone_number"` // optional
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

	// ======================
	// VALIDATION
	// ======================

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

	if !strings.Contains(user.Email, "@") {
		http.Error(w, "Invalid email format", http.StatusBadRequest)
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

	// Optional phone validation
	if user.PhoneNumber != "" {
		if len(user.PhoneNumber) != 11 || !strings.HasPrefix(user.PhoneNumber, "09") {
			http.Error(w, "Invalid phone number", http.StatusBadRequest)
			return
		}
	}

	// ======================
	// CHECK DUPLICATE EMAIL
	// ======================

	var exists bool
	err = db.QueryRow("SELECT EXISTS(SELECT 1 FROM interns WHERE email = $1)",
		user.Email).Scan(&exists)

	if err != nil {
		http.Error(w, "Error checking email", http.StatusInternalServerError)
		return
	}

	if exists {
		http.Error(w, "Email already registered", http.StatusConflict)
		return
	}

	// ======================
	// HASH PASSWORD
	// ======================

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		http.Error(w, "Error hashing password", http.StatusInternalServerError)
		return
	}

	// ======================
	// INSERT INTO DATABASE
	// ======================

	_, err = db.Exec(`
		INSERT INTO interns 
		(first_name, last_name, school, program, email, password_hash, phone_number)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`,
		user.FirstName,
		user.LastName,
		user.School,
		user.Program,
		user.Email,
		string(hashedPassword),
		user.PhoneNumber,
	)

	if err != nil {
		http.Error(w, "Error saving user", http.StatusInternalServerError)
		return
	}

	// ======================
	// RESPONSE
	// ======================

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"message": "User registered successfully",
	})
}