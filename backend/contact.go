package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"regexp"
	"strings"
)

// Contact represents the form input
type Contact struct {
	Name    string `json:"name"`
	Email   string `json:"email"`
	Message string `json:"message"`
}

// simple email regex for validation
var emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)

func ContactHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	var contact Contact
	err := json.NewDecoder(r.Body).Decode(&contact)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Input validation
	if strings.TrimSpace(contact.Name) == "" {
		http.Error(w, "Name is required", http.StatusBadRequest)
		return
	}
	if strings.TrimSpace(contact.Email) == "" || !emailRegex.MatchString(contact.Email) {
		http.Error(w, "Valid email is required", http.StatusBadRequest)
		return
	}
	if strings.TrimSpace(contact.Message) == "" {
		http.Error(w, "Message is required", http.StatusBadRequest)
		return
	}

	// Here you could save to DB or send an email
	fmt.Printf("New contact: Name=%s, Email=%s, Message=%s\n", contact.Name, contact.Email, contact.Message)

	// Respond with JSON success message
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "Message sent successfully"})
}