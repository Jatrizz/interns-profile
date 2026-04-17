package main

import (
	"database/sql"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func determineStatus(t time.Time) string {
	cutoff := time.Date(
		t.Year(),
		t.Month(),
		t.Day(),
		8, 0, 0, 0,
		t.Location(),
	)

	if t.After(cutoff) {
		return "late"
	}
	return "present"
}

func Login(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		jsonError(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	var req LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		jsonError(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// ======================
	// VALIDATION
	// ======================

	req.Email = strings.TrimSpace(strings.ToLower(req.Email))

	if req.Email == "" {
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
	// FETCH USER
	// ======================

	var user User
	var hashedPassword string
	var idNumber sql.NullString // ✅ FIX HERE

	err := db.QueryRow(`
		SELECT id, id_number, first_name, password, role
		FROM users 
		WHERE email = $1
	`, req.Email).Scan(&user.ID, &idNumber, &user.FirstName, &hashedPassword, &user.Role)

	if err == sql.ErrNoRows {
		jsonError(w, "User not found", http.StatusUnauthorized)
		return
	} else if err != nil {
		log.Println("DB ERROR:", err)
		jsonError(w, "Database error", http.StatusInternalServerError)
		return
	}

	// ✅ Assign only if valid
	if idNumber.Valid {
		user.IDNumber = idNumber.String
	} else {
		user.IDNumber = ""
	}

	// ======================
	// CHECK PASSWORD
	// ======================

	if err := bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(req.Password)); err != nil {
		jsonError(w, "Invalid password", http.StatusUnauthorized)
		return
	}

	// ======================
	// AUTO TIME-IN (ONLY INTERN)
	// ======================

	if strings.ToLower(user.Role) == "intern" && user.IDNumber != "" {
		now := time.Now()
		status := determineStatus(now)

		log.Println("Attempting time-in for:", user.IDNumber)

		res, err := db.Exec(`
			INSERT INTO attendance (id_number, date, time_in, status)
			VALUES ($1, CURRENT_DATE, $2, $3)
			ON CONFLICT (id_number, date) DO NOTHING
		`, user.IDNumber, now, status)

		if err != nil {
			log.Println("ATTENDANCE ERROR:", err)
		} else {
			rows, _ := res.RowsAffected()
			log.Println("Attendance inserted:", rows)
		}
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
		"role":       user.Role,
		"exp":        time.Now().Add(24 * time.Hour).Unix(),
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
		"role":       user.Role,
		"user_id":    strconv.Itoa(user.ID), // ✅ FIXED (was wrong before)
	})
}