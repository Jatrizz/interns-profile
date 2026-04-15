package main

import (
	"encoding/json"
	"net/http"
)

type VerifyOTPRequest struct {
	UserID int    `json:"user_id"`
	OTP    string `json:"otp"`
}

func VerifyEmailOTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	var req VerifyOTPRequest
	json.NewDecoder(r.Body).Decode(&req)

	var newEmail string
	var dbOTP string

	err := db.QueryRow(`
		SELECT new_email, otp
		FROM email_verifications
		WHERE user_id=$1
		AND expires_at > NOW()
		AND verified=false
		ORDER BY id DESC
		LIMIT 1
	`, req.UserID).Scan(&newEmail, &dbOTP)

	if err != nil {
		http.Error(w, "Invalid or expired OTP", http.StatusBadRequest)
		return
	}

	if req.OTP != dbOTP {
		http.Error(w, "Wrong OTP", http.StatusBadRequest)
		return
	}

	// mark verified
	db.Exec(`
		UPDATE email_verifications
		SET verified=true
		WHERE user_id=$1 AND otp=$2
	`, req.UserID, req.OTP)

	// update email
	_, err = db.Exec(`
		UPDATE users
		SET email=$1
		WHERE id=$2 AND role='intern'
	`, newEmail, req.UserID)

	if err != nil {
		http.Error(w, "Failed to update email", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]string{
		"message": "Email verified and updated",
	})
}