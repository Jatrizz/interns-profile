package main

import (
	"crypto/rand"
	"crypto/subtle"
	"encoding/json"
	"fmt"
	"log/slog"
	"math/big"
	"net/http"
	"net/smtp"
	"strings"

	"golang.org/x/crypto/bcrypt"
)

// ================= OTP GENERATOR =================

func generateOTP() (string, error) {
	n, err := rand.Int(rand.Reader, big.NewInt(1000000))
	if err != nil {
		return "", fmt.Errorf("failed to generate OTP: %w", err)
	}
	return fmt.Sprintf("%06d", n.Int64()), nil
}

// ================= PASSWORD VALIDATION =================
// at least 8 chars, must include uppercase, lowercase, number

func isValidPassword(pw string) bool {
	if len(pw) < 8 {
		return false
	}

	var hasUpper, hasLower, hasNumber bool

	for _, c := range pw {
		switch {
		case c >= 'A' && c <= 'Z':
			hasUpper = true
		case c >= 'a' && c <= 'z':
			hasLower = true
		case c >= '0' && c <= '9':
			hasNumber = true
		}
	}

	return hasUpper && hasLower && hasNumber
}

// ================= EMAIL SENDER =================

func sendResetOTP(toEmail, otp string) error {
	subject := "Subject: Password Reset OTP\r\n"

	body := fmt.Sprintf(`
		<h3>Password Reset Request</h3>
		<p>Your OTP code is: <b>%s</b></p>
		<p>This code will expire in 5 minutes.</p>
	`, otp)

	headers := "MIME-Version: 1.0\r\n" +
		"Content-Type: text/html; charset=\"UTF-8\"\r\n"

	message := []byte(subject + headers + "\r\n" + body)

	auth := smtp.PlainAuth("", Mail.Sender, Mail.Password, Mail.Host)

	// ✅ FIX: send to user email, NOT Mail.Receiver
	err := smtp.SendMail(
		Mail.Host+":"+Mail.Port,
		auth,
		Mail.Sender,
		[]string{toEmail}, // <-- THIS IS THE IMPORTANT FIX
		message,
	)

	if err != nil {
		slog.Error("smtp send failed",
			"to", toEmail,
			"error", err,
		)
		return fmt.Errorf("smtp error")
	}

	slog.Info("otp email sent", "to", toEmail)
	return nil
}

// ================= STEP 1: SEND OTP =================

func ForgotPasswordHandler(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Email string `json:"email"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		slog.Error("forgot.decode failed", "error", err)
		jsonError(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	req.Email = strings.TrimSpace(strings.ToLower(req.Email))

	var exists bool
	err := db.QueryRow(
		"SELECT EXISTS(SELECT 1 FROM users WHERE email=$1)",
		req.Email,
	).Scan(&exists)

	if err != nil {
		slog.Error("forgot.db check failed", "email", req.Email, "error", err)
		jsonError(w, "Database error", http.StatusInternalServerError)
		return
	}

	if !exists {
		jsonOK(w, map[string]string{
			"message": "If that email is registered, an OTP has been sent.",
		})
		return
	}

	otp, err := generateOTP()
	if err != nil {
		slog.Error("forgot.otp generate failed", "error", err)
		jsonError(w, "Failed to generate OTP", http.StatusInternalServerError)
		return
	}

	_, err = db.Exec(`
		DELETE FROM forgot_password_requests WHERE email=$1
	`, req.Email)

	if err != nil {
		slog.Warn("forgot.cleanup old otp failed", "error", err)
	}

	_, err = db.Exec(`
		INSERT INTO forgot_password_requests (email, otp, expires_at, used, verified)
		VALUES ($1, $2, NOW() + INTERVAL '5 minutes', false, false)
	`, req.Email, otp)

	if err != nil {
		slog.Error("forgot.store otp failed", "error", err)
		jsonError(w, "Failed to store OTP", http.StatusInternalServerError)
		return
	}

	if err := sendResetOTP(req.Email, otp); err != nil {
		slog.Error("forgot.smtp failed", "error", err)
		jsonError(w, "Failed to send OTP email", http.StatusInternalServerError)
		return
	}

	jsonOK(w, map[string]string{
		"message": "OTP sent to email",
	})
}

// ================= STEP 2: VERIFY OTP =================

func VerifyOTPHandler(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Email string `json:"email"`
		OTP   string `json:"otp"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		slog.Error("otp.verify decode failed", "error", err)
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
		WHERE email=$1 AND expires_at > NOW()
		ORDER BY id DESC
		LIMIT 1
	`, req.Email).Scan(&dbOTP, &used, &verified)

	if err != nil {
		slog.Warn("otp.verify not found", "email", req.Email)
		jsonError(w, "OTP not found or expired", http.StatusBadRequest)
		return
	}

	if used {
		jsonError(w, "OTP already used", http.StatusBadRequest)
		return
	}

	if subtle.ConstantTimeCompare([]byte(req.OTP), []byte(dbOTP)) != 1 {
		jsonError(w, "Invalid OTP", http.StatusBadRequest)
		return
	}

	_, err = db.Exec(`
		UPDATE forgot_password_requests
		SET verified=true
		WHERE email=$1 AND otp=$2
	`, req.Email, req.OTP)

	if err != nil {
		slog.Error("otp.verify update failed", "error", err)
		jsonError(w, "Failed to verify OTP", http.StatusInternalServerError)
		return
	}

	slog.Info("otp verified", "email", req.Email)

	jsonOK(w, map[string]string{
		"message": "OTP verified",
	})
}

// ================= STEP 3: RESET PASSWORD =================

func ResetPasswordHandler(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		jsonError(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	req.Email = strings.TrimSpace(strings.ToLower(req.Email))

	if !isValidPassword(req.Password) {
		jsonError(w,
			"Password must be 8+ chars with uppercase, lowercase, and number",
			http.StatusBadRequest,
		)
		return
	}

	var dbOTP string
	var used, verified bool

	err := db.QueryRow(`
		SELECT otp, used, verified
		FROM forgot_password_requests
		WHERE email=$1 AND expires_at > NOW()
		ORDER BY id DESC
		LIMIT 1
	`, req.Email).Scan(&dbOTP, &used, &verified)

	if err != nil {
		jsonError(w, "Session expired", http.StatusBadRequest)
		return
	}

	if !verified {
		jsonError(w, "OTP not verified", http.StatusBadRequest)
		return
	}

	if used {
		jsonError(w, "OTP already used", http.StatusBadRequest)
		return
	}

	hashed, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		jsonError(w, "Hashing failed", http.StatusInternalServerError)
		return
	}

	_, err = db.Exec(
		"UPDATE users SET password=$1 WHERE email=$2",
		string(hashed),
		req.Email,
	)

	if err != nil {
		jsonError(w, "Failed to update password", http.StatusInternalServerError)
		return
	}

	db.Exec(`
		UPDATE forgot_password_requests
		SET used=true
		WHERE email=$1 AND otp=$2
	`, req.Email, dbOTP)

	jsonOK(w, map[string]string{
		"message": "Password reset successful",
	})
}