package main

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
)

type EmailChangeRequest struct {
	UserID   int    `json:"user_id"`
	NewEmail string `json:"new_email"`
}

func SendEmailOTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	var req EmailChangeRequest
	json.NewDecoder(r.Body).Decode(&req)

	// check intern
	var exists bool
	err := db.QueryRow(`
		SELECT EXISTS(
			SELECT 1 FROM users WHERE id=$1 AND role='intern'
		)
	`, req.UserID).Scan(&exists)

	if err != nil || !exists {
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	// generate OTP
	otp := fmt.Sprintf("%06d", rand.Intn(1000000))

	// store OTP
	_, err = db.Exec(`
		INSERT INTO email_verifications (user_id, new_email, otp, expires_at)
		VALUES ($1,$2,$3,NOW() + INTERVAL '10 minutes')
	`,
		req.UserID,
		req.NewEmail,
		otp,
	)

	if err != nil {
		http.Error(w, "DB error", http.StatusInternalServerError)
		return
	}

	// send email
	err = sendOTPEmail(req.NewEmail, otp)
	if err != nil {
		http.Error(w, "Email sending failed", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]string{
		"message": "OTP sent successfully",
	})
}