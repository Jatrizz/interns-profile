package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/smtp"
	"regexp"
	"strings"
)

// ================= STRUCT =================

type Contact struct {
	Name    string `json:"name"`
	Email   string `json:"email"`
	Message string `json:"message"`
}

// ================= VALIDATION =================

var emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)

// ================= EMAIL SENDER =================

func sendContactEmail(c Contact) error {
	subject := "Subject: New Contact Form Message\r\n"

	body := fmt.Sprintf(`
		<h3>New Contact Form Submission</h3>
		<p><b>Name:</b> %s</p>
		<p><b>Email:</b> %s</p>
		<p><b>Message:</b><br>%s</p>
	`, c.Name, c.Email, c.Message)

	headers := "MIME-Version: 1.0\r\n" +
		"Content-Type: text/html; charset=\"UTF-8\"\r\n"

	message := []byte(subject + headers + "\r\n" + body)

	auth := smtp.PlainAuth("", Mail.Sender, Mail.Password, Mail.Host)

	return smtp.SendMail(
		Mail.Host+":"+Mail.Port,
		auth,
		Mail.Sender,
		[]string{Mail.Receiver},
		message,
	)
}

// ================= HANDLER =================

func ContactHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	var contact Contact
	if err := json.NewDecoder(r.Body).Decode(&contact); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// clean input
	contact.Name = strings.TrimSpace(contact.Name)
	contact.Email = strings.TrimSpace(contact.Email)
	contact.Message = strings.TrimSpace(contact.Message)

	// validation
	if contact.Name == "" {
		http.Error(w, "Name is required", http.StatusBadRequest)
		return
	}

	if contact.Email == "" || !emailRegex.MatchString(contact.Email) {
		http.Error(w, "Valid email is required", http.StatusBadRequest)
		return
	}

	if contact.Message == "" {
		http.Error(w, "Message is required", http.StatusBadRequest)
		return
	}

	// send email
	if err := sendContactEmail(contact); err != nil {
		http.Error(w, "Failed to send email", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"message": "Message sent successfully",
	})
}