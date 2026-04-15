package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
)

type EmailPayload struct {
	From    string `json:"from"`
	To      string `json:"to"`
	Subject string `json:"subject"`
	Text    string `json:"text"`
}

func sendOTPEmail(to string, otp string) error {
	payload := EmailPayload{
		From:    "Intern System <onboarding@resend.dev>",
		To:      to,
		Subject: "Email Verification OTP",
		Text:    "Your OTP code is: " + otp + "\nExpires in 10 minutes.",
	}

	body, _ := json.Marshal(payload)

	req, err := http.NewRequest(
		"POST",
		"https://api.resend.com/emails",
		bytes.NewBuffer(body),
	)
	if err != nil {
		return err
	}

	// USE HARDCODED KEY FROM main.go
	req.Header.Set("Authorization", "Bearer "+RESEND_API_KEY)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return fmt.Errorf("email sending failed: status %d", resp.StatusCode)
	}

	return nil
}