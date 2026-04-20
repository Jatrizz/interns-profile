package main

import (
	"crypto/rand"
	"encoding/json"
	"fmt"
	"log/slog"
	"math/big"
	"net/http"
	"net/smtp"
	"strings"

	"golang.org/x/crypto/bcrypt"
)

// ================= CONFIG =================

const smtpHost = "smtp.gmail.com"
const smtpPort = "587"

var smtpEmail = "internshiptestdomain@gmail.com"
var smtpPassword = "awsl qwqe vmyc sltd"

// ================= HELPERS =================

func generateOTP() string {
	n, _ := rand.Int(rand.Reader, big.NewInt(1000000))
	return fmt.Sprintf("%06d", n.Int64())
}

func sendResetOTP(toEmail, otp string) error {
	subject := "Subject: Password Reset OTP\r\n"

	body := fmt.Sprintf(`
		<h3>Password Reset Request</h3>
		<p>Your OTP code is: <b>%s</b></p>
		<p>This code will expire in 5 minutes.</p>
	`, otp)

	message := []byte(subject +
		"MIME-Version: 1.0\r\n" +
		"Content-Type: text/html; charset=\"UTF-8\"\r\n\r\n" +
		body)

	auth := smtp.PlainAuth("", smtpEmail, smtpPassword, smtpHost)

	err := smtp.SendMail(
		smtpHost+":"+smtpPort,
		auth,
		smtpEmail,
		[]string{toEmail},
		message,
	)

	if err != nil {
		slog.Error("smtp send failed", "to", toEmail, "error", err)
		return fmt.Errorf("smtp error")
	}

	slog.Info("otp email sent", "to", toEmail)
	return nil
}

// ================= STEP 1: SEND OTP =================
// POST /forgot-password
// Body: { "email": "user@example.com" }

func ForgotPasswordHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		jsonError(w, "Invalid method", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		Email string `json:"email"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		slog.Warn("invalid request body", "error", err)
		jsonError(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	req.Email = strings.TrimSpace(strings.ToLower(req.Email))

	var exists bool
	err := db.QueryRow(`SELECT EXISTS(SELECT 1 FROM users WHERE email=$1)`, req.Email).Scan(&exists)
	if err != nil {
		slog.Error("db check user failed", "email", req.Email, "error", err)
		jsonError(w, "Database error", http.StatusInternalServerError)
		return
	}

	if !exists {
		// Vague message to prevent email enumeration
		jsonOK(w, map[string]string{"message": "No account using this email."})
		return
	}

	otp := generateOTP()

	_, err = db.Exec(`DELETE FROM forgot_password_requests WHERE email=$1`, req.Email)
	if err != nil {
		slog.Error("failed to delete old otp", "email", req.Email, "error", err)
	}

	_, err = db.Exec(`
		INSERT INTO forgot_password_requests (email, otp, expires_at, used, verified)
		VALUES ($1, $2, NOW() + INTERVAL '5 minutes', false, false)
	`, req.Email, otp)
	if err != nil {
		slog.Error("failed to store otp", "email", req.Email, "error", err)
		jsonError(w, "Failed to store OTP", http.StatusInternalServerError)
		return
	}

	if err := sendResetOTP(req.Email, otp); err != nil {
		slog.Error("failed to send otp email", "email", req.Email, "error", err)
		jsonError(w, "Failed to send OTP email", http.StatusInternalServerError)
		return
	}

	jsonOK(w, map[string]string{"message": "OTP sent to email"})
}

// ================= STEP 2: VERIFY OTP =================
// POST /verify-otp
// Body: { "email": "user@example.com", "otp": "123456" }
// On success, marks the OTP row as verified so step 3 can proceed.

func VerifyOTPHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		jsonError(w, "Invalid method", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		Email string `json:"email"`
		OTP   string `json:"otp"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		slog.Warn("invalid request body", "error", err)
		jsonError(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	req.Email = strings.TrimSpace(strings.ToLower(req.Email))
	req.OTP = strings.TrimSpace(req.OTP)

	var dbOTP string
	var used, verified bool

	err := db.QueryRow(`
		SELECT otp, used, verified
		FROM forgot_password_requests
		WHERE email=$1
		  AND expires_at > NOW()
		ORDER BY id DESC
		LIMIT 1
	`, req.Email).Scan(&dbOTP, &used, &verified)

	if err != nil {
		slog.Warn("otp not found or expired", "email", req.Email, "error", err)
		jsonError(w, "OTP not found or expired", http.StatusBadRequest)
		return
	}

	if used {
		slog.Warn("otp already used", "email", req.Email)
		jsonError(w, "OTP already used", http.StatusBadRequest)
		return
	}

	if req.OTP != dbOTP {
		slog.Warn("invalid otp attempt", "email", req.Email)
		jsonError(w, "Invalid OTP", http.StatusBadRequest)
		return
	}

	// Mark as verified so the reset step knows OTP was confirmed
	_, err = db.Exec(`
		UPDATE forgot_password_requests
		SET verified=true
		WHERE email=$1 AND otp=$2
	`, req.Email, req.OTP)
	if err != nil {
		slog.Error("failed to mark otp verified", "email", req.Email, "error", err)
		jsonError(w, "Failed to verify OTP", http.StatusInternalServerError)
		return
	}

	jsonOK(w, map[string]string{"message": "OTP verified"})
}

// ================= STEP 3: RESET PASSWORD =================
// POST /reset-password
// Body: { "email": "user@example.com", "new_password": "...", "confirm_password": "..." }
// Requires the OTP to have been verified in step 2 first.

func ResetPasswordHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		jsonError(w, "Invalid method", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		Email           string `json:"email"`
		NewPassword     string `json:"new_password"`
		ConfirmPassword string `json:"confirm_password"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		slog.Warn("invalid request body", "error", err)
		jsonError(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	req.Email = strings.TrimSpace(strings.ToLower(req.Email))

	if len(req.NewPassword) < 8 {
		jsonError(w, "Password must be at least 8 characters", http.StatusBadRequest)
		return
	}

	if req.NewPassword != req.ConfirmPassword {
		jsonError(w, "Passwords do not match", http.StatusBadRequest)
		return
	}

	// Check that OTP was verified and is still within expiry
	var dbOTP string
	var used, verified bool

	err := db.QueryRow(`
		SELECT otp, used, verified
		FROM forgot_password_requests
		WHERE email=$1
		  AND expires_at > NOW()
		ORDER BY id DESC
		LIMIT 1
	`, req.Email).Scan(&dbOTP, &used, &verified)

	if err != nil {
		slog.Warn("reset session not found or expired", "email", req.Email, "error", err)
		jsonError(w, "Session expired. Please request a new OTP.", http.StatusBadRequest)
		return
	}

	if !verified {
		slog.Warn("otp not verified before reset", "email", req.Email)
		jsonError(w, "OTP not verified", http.StatusBadRequest)
		return
	}

	if used {
		slog.Warn("otp already used", "email", req.Email)
		jsonError(w, "OTP already used", http.StatusBadRequest)
		return
	}

	hashed, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		slog.Error("password hashing failed", "error", err)
		jsonError(w, "Failed to hash password", http.StatusInternalServerError)
		return
	}

	_, err = db.Exec(`
		UPDATE users SET password=$1 WHERE email=$2
	`, string(hashed), req.Email)
	if err != nil {
		slog.Error("password update failed", "email", req.Email, "error", err)
		jsonError(w, "Failed to update password", http.StatusInternalServerError)
		return
	}

	_, err = db.Exec(`
		UPDATE forgot_password_requests
		SET used=true
		WHERE email=$1 AND otp=$2
	`, req.Email, dbOTP)
	if err != nil {
		slog.Error("failed to mark otp used", "email", req.Email, "error", err)
	}

	jsonOK(w, map[string]string{"message": "Password reset successful"})
}