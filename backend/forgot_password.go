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
	"time"

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
	subject := "Reset Your Password"

	// Build individual digit boxes
	digits := strings.Split(otp, "")
	digitBoxes := ""
	for _, d := range digits {
		digitBoxes += fmt.Sprintf(`
			<td style="padding: 0 6px;">
				<div style="
					width: 48px;
					height: 56px;
					background-color: #F3F4F6;
					border-radius: 10px;
					font-size: 28px;
					font-weight: 700;
					color: #111827;
					text-align: center;
					line-height: 56px;
					font-family: 'Courier New', monospace;
				">%s</div>
			</td>
		`, d)
	}

	body := fmt.Sprintf(`
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Password Reset</title>
</head>
<body style="margin:0;padding:0;background-color:#F0F2F5;font-family:'Segoe UI',Arial,sans-serif;">
  <table width="100%%" cellpadding="0" cellspacing="0" style="padding: 48px 16px;">
    <tr>
      <td align="center">
        <table width="560" cellpadding="0" cellspacing="0" style="
          background-color: #ffffff;
          border-radius: 20px;
          overflow: hidden;
          box-shadow: 0 4px 24px rgba(0,0,0,0.08);
        ">

          <!-- Header -->
          <tr>
            <td align="center" style="
              background: linear-gradient(135deg, #DC2626 0%%, #B91C1C 100%%);
              padding: 36px 40px 28px;
            ">
              <table cellpadding="0" cellspacing="0">
                <tr>
                  <td align="center">
                    <div style="
                      background: rgba(255,255,255,0.15);
                      border-radius: 16px;
                      padding: 12px 20px;
                      margin-bottom: 16px;
                      display: inline-block;
                    ">
                      <span style="font-size: 28px;">🔑</span>
                    </div>
                  </td>
                </tr>
                <tr>
                  <td align="center">
                    <h1 style="
                      margin: 0;
                      color: #ffffff;
                      font-size: 24px;
                      font-weight: 700;
                      letter-spacing: -0.5px;
                    ">Password Reset</h1>
                  </td>
                </tr>
                <tr>
                  <td align="center">
                    <p style="
                      margin: 8px 0 0;
                      color: rgba(255,255,255,0.80);
                      font-size: 14px;
                    ">Internship Management System</p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding: 40px 48px 32px;">
              <p style="margin: 0 0 8px; font-size: 15px; color: #374151;">Hello,</p>
              <p style="margin: 0 0 28px; font-size: 15px; color: #374151; line-height: 1.6;">
                We received a request to reset your password. Use the one-time code below to proceed. If you did not request this, you can safely ignore this email.
              </p>

              <!-- OTP Box -->
              <table width="100%%" cellpadding="0" cellspacing="0" style="margin-bottom: 28px;">
                <tr>
                  <td align="center">
                    <table cellpadding="0" cellspacing="0" style="
                      background: #F9FAFB;
                      border: 1.5px dashed #D1D5DB;
                      border-radius: 14px;
                      padding: 28px 24px;
                    ">
                      <tr>
                        <td align="center">
                          <p style="
                            margin: 0 0 16px;
                            font-size: 12px;
                            font-weight: 600;
                            color: #6B7280;
                            letter-spacing: 1.5px;
                            text-transform: uppercase;
                          ">Your reset code</p>
                        </td>
                      </tr>
                      <tr>
                        <td align="center">
                          <table cellpadding="0" cellspacing="0" style="margin: 0 auto;">
                            <tr>
                              %s
                            </tr>
                          </table>
                        </td>
                      </tr>
                      <tr>
                        <td align="center">
                          <p style="
                            margin: 16px 0 0;
                            font-size: 12px;
                            color: #9CA3AF;
                          ">⏱ Expires in <strong style="color: #EF4444;">5 minutes</strong></p>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>

              <!-- Warning Box -->
              <table width="100%%" cellpadding="0" cellspacing="0" style="margin-bottom: 8px;">
                <tr>
                  <td style="
                    background: #FFF7ED;
                    border: 1px solid #FED7AA;
                    border-radius: 10px;
                    padding: 14px 18px;
                  ">
                    <p style="margin: 0; font-size: 13px; color: #92400E; line-height: 1.6;">
                      ⚠️ <strong>Never share this code</strong> with anyone. Our team will never ask for your OTP.
                    </p>
                  </td>
                </tr>
              </table>

              <p style="margin: 16px 0 0; font-size: 13px; color: #6B7280; line-height: 1.6;">
                If you did not request a password reset, please secure your account immediately by changing your password.
              </p>
            </td>
          </tr>

          <!-- Divider -->
          <tr>
            <td style="padding: 0 48px;">
              <hr style="border: none; border-top: 1px solid #E5E7EB; margin: 0;" />
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td align="center" style="padding: 24px 48px 36px;">
              <p style="margin: 0 0 4px; font-size: 12px; color: #9CA3AF;">
                This email was sent by the Internship Management System.
              </p>
              <p style="margin: 0; font-size: 12px; color: #9CA3AF;">
                &copy; %d All rights reserved.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
	`, digitBoxes, time.Now().Year())

	message := []byte(
		"From: Internship System <" + Mail.Sender + ">\r\n" +
			"To: " + toEmail + "\r\n" +
			"Subject: " + subject + "\r\n" +
			"MIME-Version: 1.0\r\n" +
			"Content-Type: text/html; charset=\"UTF-8\"\r\n\r\n" +
			body,
	)

	auth := smtp.PlainAuth("", Mail.Sender, Mail.Password, Mail.Host)
	if err := smtp.SendMail(Mail.Host+":"+Mail.Port, auth, Mail.Sender, []string{toEmail}, message); err != nil {
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

	_, err = db.Exec(`DELETE FROM forgot_password_requests WHERE email=$1`, req.Email)
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