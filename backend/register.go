package main

import (
	"encoding/json"
	"fmt"
	"log"
	"log/slog"
	"math/rand"
	"net/http"
	"net/smtp"
	"regexp"
	"strings"
	"time"

	"golang.org/x/crypto/bcrypt"
)

// ================= HELPERS =================

func jsonError(w http.ResponseWriter, msg string, code int) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	json.NewEncoder(w).Encode(map[string]string{"error": msg})
}

func jsonOK(w http.ResponseWriter, payload any) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(payload)
}

// ================= GENERATE INTERN ID =================

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
	return fmt.Sprintf("%d-%03d", year, lastNumber+1), nil
}

// ================= SEND OTP EMAIL =================

func sendOTPEmailSMTP(toEmail, otp string) error {
	smtpHost := "smtp.gmail.com"
	smtpPort := "587"

	from := "internshiptestdomain@gmail.com"
	password := "awsl qwqe vmyc sltd"

	subject := "Your OTP Verification Code"

	digits := strings.Split(otp, "")
	digitBoxes := ""
	for _, d := range digits {
		digitBoxes += fmt.Sprintf(`
			<td style="padding: 0 6px;">
				<table cellpadding="0" cellspacing="0" style="
					width: 48px;
					height: 56px;
					background-color: #F3F4F6;
					border-radius: 10px;
				">
					<tr>
						<td align="center" valign="middle" style="
							font-size: 28px;
							font-weight: 700;
							color: #111827;
							font-family: 'Courier New', monospace;
							text-align: center;
							vertical-align: middle;
							width: 48px;
							height: 56px;
						">%s</td>
					</tr>
				</table>
			</td>
		`, d)
	}

	body := fmt.Sprintf(`
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>OTP Verification</title>
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
              background: linear-gradient(135deg, #4F46E5 0%%, #7C3AED 100%%);
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
                      <span style="font-size: 28px;">🔐</span>
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
                    ">Verify Your Account</h1>
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
                We received a request to verify your email address. Use the one-time code below to complete your registration.
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
                          ">Your verification code</p>
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

              <p style="margin: 0 0 8px; font-size: 13px; color: #6B7280; line-height: 1.6;">
                If you did not attempt to register, you can safely ignore this email. This code will expire shortly.
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
		"From: Internship System <" + from + ">\r\n" +
			"To: " + toEmail + "\r\n" +
			"Subject: " + subject + "\r\n" +
			"MIME-Version: 1.0\r\n" +
			"Content-Type: text/html; charset=\"UTF-8\"\r\n\r\n" +
			body,
	)

	auth := smtp.PlainAuth("", from, password, smtpHost)
	if err := smtp.SendMail(smtpHost+":"+smtpPort, auth, from, []string{toEmail}, message); err != nil {
		return fmt.Errorf("smtp send failed: %w", err)
	}

	return nil
}

// ================= STEP 1: REGISTER (validate + send OTP) =================

func registerHandler(w http.ResponseWriter, r *http.Request) {
	var user struct {
		FirstName   string `json:"first_name"`
		LastName    string `json:"last_name"`
		School      string `json:"school"`
		Program     string `json:"program"`
		Email       string `json:"email"`
		Password    string `json:"password"`
		PhoneNumber string `json:"phone_number"`
	}

	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		jsonError(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	user.Email = strings.TrimSpace(strings.ToLower(user.Email))
	phone := strings.TrimSpace(user.PhoneNumber)

	validationErrors := map[string]string{}

	if strings.TrimSpace(user.FirstName) == "" {
		validationErrors["first_name"] = "Required"
	}
	if strings.TrimSpace(user.LastName) == "" {
		validationErrors["last_name"] = "Required"
	}
	if strings.TrimSpace(user.School) == "" {
		validationErrors["school"] = "Required"
	}
	if strings.TrimSpace(user.Program) == "" {
		validationErrors["program"] = "Required"
	}
	if !strings.Contains(user.Email, "@") || !strings.Contains(user.Email, ".") {
		validationErrors["email"] = "Invalid email address"
	}
	if len(user.Password) < 8 {
		validationErrors["password"] = "Minimum 8 characters"
	}
	matched, _ := regexp.MatchString(`^09\d{9}$`, phone)
	if !matched {
		validationErrors["phone_number"] = "Must be a valid PH number (e.g. 09XXXXXXXXX)"
	}

	if len(validationErrors) > 0 {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(validationErrors)
		return
	}

	var exists bool
	if err := db.QueryRow(`SELECT EXISTS(SELECT 1 FROM users WHERE email=$1)`, user.Email).Scan(&exists); err != nil {
		jsonError(w, "Database error", http.StatusInternalServerError)
		return
	}
	if exists {
		jsonError(w, "Email already registered", http.StatusConflict)
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		jsonError(w, "Failed to hash password", http.StatusInternalServerError)
		return
	}

	rng := rand.New(rand.NewSource(time.Now().UnixNano()))
	otp := fmt.Sprintf("%06d", rng.Intn(1000000))

	_, _ = db.Exec(`DELETE FROM pending_registrations WHERE email = $1`, user.Email)

	_, err = db.Exec(`
		INSERT INTO pending_registrations (first_name, last_name, school, program, email, password, phone_number, otp, expires_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW() + INTERVAL '5 minutes')
	`,
		strings.TrimSpace(user.FirstName),
		strings.TrimSpace(user.LastName),
		strings.TrimSpace(user.School),
		strings.TrimSpace(user.Program),
		user.Email,
		string(hashedPassword),
		phone,
		otp,
	)
	if err != nil {
		log.Printf("[REGISTER] database insert failed | error=%v", err)
		jsonError(w, "Unable to complete registration at the moment.", http.StatusInternalServerError)
		return
	}

	if err := sendOTPEmailSMTP(user.Email, otp); err != nil {
		jsonError(w, "Failed to send OTP email", http.StatusInternalServerError)
		return
	}

	jsonOK(w, map[string]string{
		"message": "OTP sent to " + user.Email + ". Please verify to complete registration.",
	})
}

// ================= STEP 2: VERIFY OTP + CREATE ACCOUNT =================

func VerifyOTP(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Email string `json:"email"`
		OTP   string `json:"otp"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		jsonError(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	req.Email = strings.TrimSpace(strings.ToLower(req.Email))
	req.OTP = strings.TrimSpace(req.OTP)

	var pending struct {
		FirstName   string
		LastName    string
		School      string
		Program     string
		Password    string
		PhoneNumber string
		OTP         string
	}

	err := db.QueryRow(`
		SELECT first_name, last_name, school, program, password, phone_number, otp
		FROM pending_registrations
		WHERE email = $1
		  AND expires_at > NOW()
		ORDER BY id DESC
		LIMIT 1
	`, req.Email).Scan(
		&pending.FirstName,
		&pending.LastName,
		&pending.School,
		&pending.Program,
		&pending.Password,
		&pending.PhoneNumber,
		&pending.OTP,
	)
	if err != nil {
		slog.Warn("pending registration not found or expired",
			"email", req.Email,
			"error", err,
			"handler", "VerifyOTP",
		)
		jsonError(w, "Registration request not found or expired. Please register again.", http.StatusBadRequest)
		return
	}

	if req.OTP != pending.OTP {
		jsonError(w, "Incorrect OTP", http.StatusBadRequest)
		return
	}

	var exists bool
	if err := db.QueryRow(`SELECT EXISTS(SELECT 1 FROM users WHERE email=$1)`, req.Email).Scan(&exists); err != nil {
		jsonError(w, "Database error", http.StatusInternalServerError)
		return
	}
	if exists {
		jsonError(w, "Email already registered", http.StatusConflict)
		return
	}

	internID, err := generateInternID()
	if err != nil {
		jsonError(w, "Failed to generate intern ID", http.StatusInternalServerError)
		return
	}

	_, err = db.Exec(`
		INSERT INTO users (id_number, first_name, last_name, school, program, email, password, phone_number, role)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'intern')
	`,
		internID,
		pending.FirstName,
		pending.LastName,
		pending.School,
		pending.Program,
		req.Email,
		pending.Password,
		pending.PhoneNumber,
	)
	if err != nil {
		fmt.Println("INSERT ERROR:", err.Error())
		jsonError(w, err.Error(), http.StatusInternalServerError)
		return
	}

	db.Exec(`DELETE FROM pending_registrations WHERE email = $1`, req.Email)

	jsonOK(w, map[string]string{
		"message":   "Account created successfully",
		"intern_id": internID,
	})
}