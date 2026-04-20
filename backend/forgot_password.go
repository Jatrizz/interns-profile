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

func ForgotPasswordHandler(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodPost {
        jsonError(w, "Invalid method", http.StatusMethodNotAllowed)
        return
    }

    var req struct {
        Email string `json:"email"`
    }

    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
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
        jsonError(w, "Database error", http.StatusInternalServerError)
        return
    }

    if !exists {
        jsonOK(w, map[string]string{"message": "No account using this email."})
        return
    }

    otp := generateOTP()

    _, _ = db.Exec(
        "DELETE FROM forgot_password_requests WHERE email=$1",
        req.Email,
    )

    _, err = db.Exec(`
        INSERT INTO forgot_password_requests (email, otp, expires_at, used, verified)
        VALUES ($1, $2, NOW() + INTERVAL '5 minutes', false, false)
    `, req.Email, otp)

    if err != nil {
        jsonError(w, "Failed to store OTP", http.StatusInternalServerError)
        return
    }

    if err := sendResetOTP(req.Email, otp); err != nil {
        jsonError(w, "Failed to send OTP email", http.StatusInternalServerError)
        return
    }

    jsonOK(w, map[string]string{"message": "OTP sent to email"})
}

// ================= STEP 2: VERIFY OTP =================

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
        jsonError(w, "OTP not found or expired", http.StatusBadRequest)
        return
    }

    if used {
        jsonError(w, "OTP already used", http.StatusBadRequest)
        return
    }

    if req.OTP != dbOTP {
        jsonError(w, "Invalid OTP", http.StatusBadRequest)
        return
    }

    _, err = db.Exec(`
        UPDATE forgot_password_requests
        SET verified=true
        WHERE email=$1 AND otp=$2
    `, req.Email, req.OTP)

    if err != nil {
        jsonError(w, "Failed to verify OTP", http.StatusInternalServerError)
        return
    }

    jsonOK(w, map[string]string{"message": "OTP verified"})
}

// ================= STEP 3: RESET PASSWORD =================

func ResetPasswordHandler(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodPost {
        jsonError(w, "Invalid method", http.StatusMethodNotAllowed)
        return
    }

    var req struct {
        Email    string `json:"email"`
        Password string `json:"password"`
    }

    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        jsonError(w, "Invalid request body", http.StatusBadRequest)
        return
    }

    req.Email = strings.TrimSpace(strings.ToLower(req.Email))

    if len(req.Password) < 8 {
        jsonError(w, "Password must be at least 8 characters", http.StatusBadRequest)
        return
    }

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
        jsonError(w, "Session expired. Request new OTP.", http.StatusBadRequest)
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

    _, _ = db.Exec(
        "UPDATE forgot_password_requests SET used=true WHERE email=$1 AND otp=$2",
        req.Email,
        dbOTP,
    )

    jsonOK(w, map[string]string{"message": "Password reset successful"})
}