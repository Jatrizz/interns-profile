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

// ================= CONFIG =================

const smtpHost = "smtp.gmail.com"
const smtpPort = "587"

var smtpEmail = "internshiptestdomain@gmail.com"
var smtpPassword = "awsl qwqe vmyc sltd"

// ================= HELPERS =================

func generateOTP() (string, error) {
	n, err := rand.Int(rand.Reader, big.NewInt(1000000))
	if err != nil {
		return "", fmt.Errorf("failed to generate OTP: %w", err)
	}
	return fmt.Sprintf("%06d", n.Int64()), nil
}

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
		// ✅ allow everything else (special chars)
		}
	}

	return hasUpper && hasLower && hasNumber
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

func ForgotPasswordHandler(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Email string `json:"email"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		slog.Error("failed to decode request body", "error", err)
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
		slog.Error("failed to query user existence", "email", req.Email, "error", err)
		jsonError(w, "Database error", http.StatusInternalServerError)
		return
	}

	if !exists {
		jsonOK(w, map[string]string{"message": "If that email is registered, an OTP has been sent."})
		return
	}

	otp, err := generateOTP()
	if err != nil {
		slog.Error("failed to generate OTP", "email", req.Email, "error", err)
		jsonError(w, "Failed to generate OTP", http.StatusInternalServerError)
		return
	}

	_, err = db.Exec(
		"DELETE FROM forgot_password_requests WHERE email=$1",
		req.Email,
	)
	if err != nil {
		slog.Error("failed to delete old OTP records", "email", req.Email, "error", err)
	}

	_, err = db.Exec(`
		INSERT INTO forgot_password_requests (email, otp, expires_at, used, verified)
		VALUES ($1, $2, NOW() + INTERVAL '5 minutes', false, false)
	`, req.Email, otp)

	if err != nil {
		slog.Error("failed to store OTP", "email", req.Email, "error", err)
		jsonError(w, "Failed to store OTP", http.StatusInternalServerError)
		return
	}

	if err := sendResetOTP(req.Email, otp); err != nil {
		slog.Error("failed to send OTP email", "email", req.Email, "error", err)
		jsonError(w, "Failed to send OTP email", http.StatusInternalServerError)
		return
	}

	jsonOK(w, map[string]string{"message": "An OTP has been sent to email."})
}

// ================= STEP 2: VERIFY OTP =================

func VerifyOTPHandler(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Email string `json:"email"`
		OTP   string `json:"otp"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		slog.Error("otp.verify decode failed",
			"error", err,
			"handler", "VerifyOTPHandler",
		)
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
		slog.Warn("otp.verify record not found",
			"email", req.Email,
			"error", err,
		)
		jsonError(w, "OTP not found or expired", http.StatusBadRequest)
		return
	}

	if used {
		slog.Warn("otp.verify already used",
			"email", req.Email,
		)
		jsonError(w, "OTP already used", http.StatusBadRequest)
		return
	}

	if subtle.ConstantTimeCompare([]byte(req.OTP), []byte(dbOTP)) != 1 {
		slog.Warn("otp.verify mismatch",
			"email", req.Email,
		)
		jsonError(w, "Invalid OTP", http.StatusBadRequest)
		return
	}

	_, err = db.Exec(`
		UPDATE forgot_password_requests
		SET verified=true
		WHERE email=$1 AND otp=$2
	`, req.Email, req.OTP)

	if err != nil {
		slog.Error("otp.verify update failed",
			"email", req.Email,
			"error", err,
		)
		jsonError(w, "Failed to verify OTP", http.StatusInternalServerError)
		return
	}

	slog.Info("otp.verify success",
		"email", req.Email,
	)

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
		slog.Error("reset.decode failed",
			"error", err,
			"handler", "ResetPasswordHandler",
		)
		jsonError(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	req.Email = strings.TrimSpace(strings.ToLower(req.Email))

	if !isValidPassword(req.Password) {
		slog.Warn("reset.invalid password format",
			"email", req.Email,
		)
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
		slog.Warn("reset.otp session missing",
			"email", req.Email,
			"error", err,
		)
		jsonError(w, "Session expired. Request a new OTP.", http.StatusBadRequest)
		return
	}

	if !verified {
		slog.Warn("reset.unverified attempt",
			"email", req.Email,
		)
		jsonError(w, "OTP not verified", http.StatusBadRequest)
		return
	}

	if used {
		slog.Warn("reset.otp already used",
			"email", req.Email,
		)
		jsonError(w, "OTP already used", http.StatusBadRequest)
		return
	}

	hashed, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		slog.Error("reset.hash failed",
			"email", req.Email,
			"error", err,
		)
		jsonError(w, "Hashing failed", http.StatusInternalServerError)
		return
	}

	_, err = db.Exec(
		"UPDATE users SET password=$1 WHERE email=$2",
		string(hashed),
		req.Email,
	)

	if err != nil {
		slog.Error("reset.password update failed",
			"email", req.Email,
			"error", err,
		)
		jsonError(w, "Failed to update password", http.StatusInternalServerError)
		return
	}

	_, err = db.Exec(`
		UPDATE forgot_password_requests
		SET used=true
		WHERE email=$1 AND otp=$2
	`, req.Email, dbOTP)

	if err != nil {
		slog.Error("reset.mark used failed",
			"email", req.Email,
			"error", err,
		)
	}

	slog.Info("reset.password success",
		"email", req.Email,
	)

	jsonOK(w, map[string]string{
		"message": "Password reset successful",
	})
}