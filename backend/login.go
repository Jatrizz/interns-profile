package main

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func Login(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	var req LoginRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		jsonError(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// ======================
	// VALIDATION
	// ======================

	if strings.TrimSpace(req.Email) == "" {
		jsonError(w, "Email is required", http.StatusBadRequest)
		return
	}

	if !strings.Contains(req.Email, "@") {
		jsonError(w, "Invalid email format", http.StatusBadRequest)
		return
	}

	if strings.TrimSpace(req.Password) == "" {
		jsonError(w, "Password is required", http.StatusBadRequest)
		return
	}

	// ======================
	// FETCH USER BY EMAIL
	// ======================

	var user User
	var hashedPassword string

	err = db.QueryRow(`
		SELECT id, first_name, password
		FROM users 
		WHERE email = $1
	`, req.Email).Scan(&user.ID, &user.FirstName, &hashedPassword)

	if err == sql.ErrNoRows {
		http.Error(w, "User not found", http.StatusUnauthorized)
		return
	} else if err != nil {
		http.Error(w, "Error finding user", http.StatusInternalServerError)
		return
	}

	// ======================
	// CHECK PASSWORD
	// ======================

	err = bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(req.Password))
	if err != nil {
		jsonError(w, "Invalid password", http.StatusUnauthorized)
		return
	}

	// ======================
	// GENERATE JWT
	// ======================

	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		secret = "your-secret-key"
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"id":         user.ID,
		"first_name": user.FirstName,
		"exp":        time.Now().Add(time.Hour * 24).Unix(),
	})

	tokenString, err := token.SignedString([]byte(secret))
	if err != nil {
		jsonError(w, "Error generating token", http.StatusInternalServerError)
		return
	}

	// ======================
	// RESPONSE
	// ======================

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"message":    "Login successful",
		"first_name": user.FirstName,
		"token":      tokenString,
	})
}
