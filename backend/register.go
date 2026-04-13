package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"regexp"
	"strings"
	"time"

	"golang.org/x/crypto/bcrypt"
)

// User struct
type User struct {
	ID          int    `json:"id"`
	FirstName   string `json:"first_name"`
	LastName    string `json:"last_name"`
	School      string `json:"school"`
	Program     string `json:"program"`
	Email       string `json:"email"`
	Password    string `json:"password"`
	PhoneNumber string `json:"phone_number"`
	Role        string `json:"role"`
}

func jsonError(w http.ResponseWriter, message string, statusCode int) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	json.NewEncoder(w).Encode(map[string]string{
		"error": message})
}

// 🔧 Generate Intern ID: YYYY-XXX
func generateInternID() (string, error) {
	year := time.Now().Year()

	var lastNumber int
	err := db.QueryRow(`
		SELECT COALESCE(MAX(CAST(SPLIT_PART(id_number, '-', 2) AS INT)), 0)
		FROM users
		WHERE EXTRACT(YEAR FROM created_at) = $1
	`, year).Scan(&lastNumber)

	if err != nil {
		return "", err
	}

	newNumber := lastNumber + 1
	internID := fmt.Sprintf("%d-%03d", year, newNumber)

	return internID, nil
}

func registerHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusOK)
		return
	}

	w.Header().Set("Content-Type", "application/json")

	var user User
	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		jsonError(w, "Invalid request body: "+err.Error(), http.StatusBadRequest)
		return
	}

	errors := map[string]string{}

	// ---------------- VALIDATION ----------------

	if strings.TrimSpace(user.FirstName) == "" {
		errors["first_name"] = "First name is required"
	}
	if strings.TrimSpace(user.LastName) == "" {
		errors["last_name"] = "Last name is required"
	}
	if strings.TrimSpace(user.School) == "" {
		errors["school"] = "School is required"
	}
	if strings.TrimSpace(user.Program) == "" {
		errors["program"] = "Program is required"
	}

	if strings.TrimSpace(user.Email) == "" {
		errors["email"] = "Email is required"
	} else if !strings.Contains(user.Email, "@") {
		errors["email"] = "Invalid email format"
	}

	if strings.TrimSpace(user.Password) == "" {
		errors["password"] = "Password is required"
	} else if len(user.Password) < 8 {
		errors["password"] = "Password must be at least 8 characters"
	}

	// 📱 Phone validation
	phone := strings.TrimSpace(user.PhoneNumber)

	if phone == "" {
		errors["phone_number"] = "Phone number is required"
	} else {
		matched, _ := regexp.MatchString(`^09\d{9}$`, phone)
		if !matched {
			errors["phone_number"] = "Phone must start with 09 and be 11 digits"
		}
	}

	// If validation failed
	if len(errors) > 0 {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]interface{}{"errors": errors})
		return
	}

	// ---------------- DUPLICATE CHECK ----------------

	var exists bool

	// Email duplicate
	err := db.QueryRow(
		"SELECT EXISTS(SELECT 1 FROM users WHERE email=$1)",
		user.Email,
	).Scan(&exists)

	if err != nil {
		jsonError(w, "Database error: "+err.Error(), http.StatusInternalServerError)
		return
	}
	if exists {
		errors["email"] = "Email already registered"
	}

	// Phone duplicate
	err = db.QueryRow(
		"SELECT EXISTS(SELECT 1 FROM users WHERE phone_number=$1)",
		phone,
	).Scan(&exists)

	if err != nil {
		jsonError(w, "Database error: "+err.Error(), http.StatusInternalServerError)
		return
	}
	if exists {
		errors["phone_number"] = "Phone number already registered"
	}

	if len(errors) > 0 {
		w.WriteHeader(http.StatusConflict)
		json.NewEncoder(w).Encode(map[string]interface{}{"errors": errors})
		return
	}

	// ---------------- GENERATE INTERN ID ----------------

	internID, err := generateInternID()
	if err != nil {
		jsonError(w, "Failed to generate intern ID: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// ---------------- HASH PASSWORD ----------------

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		jsonError(w, "Password hashing failed: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// ---------------- INSERT ----------------

	_, err = db.Exec(`
    INSERT INTO users (
        id_number,
        first_name,
        last_name,
        school,
        program,
        email,
        password,
        phone_number
    )
    VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
`,
		internID,
		user.FirstName,
		user.LastName,
		user.School,
		user.Program,
		user.Email,
		string(hashedPassword),
		phone,
	)

	if err != nil {
		jsonError(w, "Failed to save user: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// ---------------- RESPONSE ----------------

	json.NewEncoder(w).Encode(map[string]string{
		"message":   "User registered successfully",
		"intern_id": internID,
	})
}
