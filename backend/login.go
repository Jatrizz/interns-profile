package main

import (
	"database/sql"
	"encoding/json"
	"log"
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
	// FETCH USER
	// ======================

	var user User
	var hashedPassword string

	err = db.QueryRow(`
		SELECT id, intern_id, first_name, password, role
		FROM users 
		WHERE email = $1
	`, req.Email).Scan(&user.ID, &user.FirstName, &hashedPassword, &user.Role)

	if err == sql.ErrNoRows {
		jsonError(w, "User not found", http.StatusUnauthorized)
		return
	} else if err != nil {
		jsonError(w, "Error finding user"+err.Error(), http.StatusInternalServerError)
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
	// AUTO TIME-IN (UPDATED)
	// ======================

	if strings.ToLower(strings.TrimSpace(user.Role)) == "intern" {
		now := time.Now()
		status := determineStatus(now)

		log.Println("Attempting time-in for intern_id:", user.ID)

		res, err := db.Exec(`
			INSERT INTO attendance (intern_id, date, time_in, status)
			VALUES ($1, CURRENT_DATE, $2, $3)
			ON CONFLICT (intern_id, date) DO NOTHING
		`, user.ID, now, status)

		if err != nil {
			log.Println("ATTENDANCE ERROR:", err)
		} else {
			rows, _ := res.RowsAffected()
			log.Println("Attendance rows inserted:", rows)
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
		"role":       user.Role,
		"user_id":    string(rune(user.ID)),
	})
}