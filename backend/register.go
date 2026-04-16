package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"regexp"
	"strings"
	"time"

	"golang.org/x/crypto/bcrypt"
)

const resendURL = "https://api.resend.com/emails"

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

func sendOTPEmailResend(toEmail, otp string) error {
	payload := map[string]interface{}{
		"from":    "onboarding@resend.dev",
		"to":      []string{toEmail},
		"subject": "Your OTP Code",
		"html":    fmt.Sprintf("<h2>Your OTP is: <strong>%s</strong></h2><p>Valid for 10 minutes. Do not share this code.</p>", otp),
	}

	body, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("failed to marshal payload: %w", err)
	}

	req, err := http.NewRequest("POST", resendURL, bytes.NewBuffer(body))
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Authorization", "Bearer "+RESEND_API_KEY)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 300 {
		return fmt.Errorf("resend API returned status %d", resp.StatusCode)
	}

	return nil
}

// ================= STEP 1: REGISTER (validate + send OTP) =================
// POST /register
// User submits all fields. If valid, OTP is sent to email.

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

	// -------- VALIDATION --------

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

	// -------- CHECK DUPLICATE EMAIL --------

	var exists bool
	if err := db.QueryRow(`SELECT EXISTS(SELECT 1 FROM users WHERE email=$1)`, user.Email).Scan(&exists); err != nil {
		jsonError(w, "Database error", http.StatusInternalServerError)
		return
	}
	if exists {
		jsonError(w, "Email already registered", http.StatusConflict)
		return
	}

	// -------- HASH PASSWORD --------

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		jsonError(w, "Failed to hash password", http.StatusInternalServerError)
		return
	}

	// -------- GENERATE OTP --------

	rng := rand.New(rand.NewSource(time.Now().UnixNano()))
	otp := fmt.Sprintf("%06d", rng.Intn(1000000))

	// -------- STORE PENDING REGISTRATION --------
	// Delete any previous pending attempt for this email first

	_, _ = db.Exec(`DELETE FROM pending_registrations WHERE email = $1`, user.Email)

	_, err = db.Exec(`
		INSERT INTO pending_registrations (first_name, last_name, school, program, email, password, phone_number, otp, expires_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW() + INTERVAL '10 minutes')
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
		fmt.Println("PENDING INSERT ERROR:", err.Error())
		jsonError(w, "Failed to store registration", http.StatusInternalServerError)
		return
	}

	// -------- SEND OTP --------

	if err := sendOTPEmailResend(user.Email, otp); err != nil {
		jsonError(w, "Failed to send OTP email", http.StatusInternalServerError)
		return
	}

	jsonOK(w, map[string]string{
		"message": "OTP sent to " + user.Email + ". Please verify to complete registration.",
	})
}

// ================= STEP 2: VERIFY OTP + CREATE ACCOUNT =================
// POST /verify-otp
// Body: { "email": "...", "otp": "123456" }

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

	// -------- FETCH PENDING REGISTRATION --------

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
		jsonError(w, "Registration request not found or expired. Please register again.", http.StatusBadRequest)
		return
	}

	// -------- VERIFY OTP --------

	if req.OTP != pending.OTP {
		jsonError(w, "Incorrect OTP", http.StatusBadRequest)
		return
	}

	// -------- FINAL DUPLICATE CHECK --------

	var exists bool
	if err := db.QueryRow(`SELECT EXISTS(SELECT 1 FROM users WHERE email=$1)`, req.Email).Scan(&exists); err != nil {
		jsonError(w, "Database error", http.StatusInternalServerError)
		return
	}
	if exists {
		jsonError(w, "Email already registered", http.StatusConflict)
		return
	}

	// -------- GENERATE INTERN ID --------

	internID, err := generateInternID()
	if err != nil {
		jsonError(w, "Failed to generate intern ID", http.StatusInternalServerError)
		return
	}

	// -------- CREATE USER --------

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

	// -------- CLEANUP --------

	db.Exec(`DELETE FROM pending_registrations WHERE email = $1`, req.Email)

	jsonOK(w, map[string]string{
		"message":   "Account created successfully",
		"intern_id": internID,
	})
}