package main

import (
	"encoding/base64"
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

// ================= HELPERS =================
func encodeBase64Subject(s string) string {
	return base64.StdEncoding.EncodeToString([]byte(s))
}

// ================= EMAIL SENDER =================
func sendContactEmail(c Contact) error {
	subject := "Subject: =?UTF-8?B?" + encodeBase64Subject("📬 New Message from "+c.Name) + "?=\r\n"

	body := fmt.Sprintf(`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Contact Form</title>
</head>
<body style="margin:0;padding:0;background-color:#f4f4f7;font-family:'Segoe UI',Arial,sans-serif;">
  <table width="100%%" cellpadding="0" cellspacing="0" style="background-color:#f4f4f7;padding:40px 0;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:8px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td style="background:linear-gradient(135deg,#58A7E7,#4127EB);padding:36px 40px;">
              <h1 style="margin:0;color:#ffffff;font-size:22px;font-weight:600;letter-spacing:0.3px;">
                New Contact Message
              </h1>
              <p style="margin:6px 0 0;color:rgba(255,255,255,0.75);font-size:13px;">
                Received via Orbis contact form
              </p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:36px 40px;">

              <!-- Sender Info -->
              <table width="100%%" cellpadding="0" cellspacing="0" style="margin-bottom:28px;">
                <tr>
                  <td style="padding:14px 16px;background:#f9f9fb;border-left:3px solid #58A7E7;border-radius:4px;">
                    <p style="margin:0 0 4px;font-size:11px;text-transform:uppercase;letter-spacing:0.8px;color:#999999;">From</p>
                    <p style="margin:0;font-size:15px;font-weight:600;color:#111111;">%s</p>
                    <p style="margin:2px 0 0;font-size:13px;color:#555555;">%s</p>
                  </td>
                </tr>
              </table>

              <!-- Message -->
              <p style="margin:0 0 10px;font-size:11px;text-transform:uppercase;letter-spacing:0.8px;color:#999999;">Message</p>
              <table width="100%%" cellpadding="0" cellspacing="0">
                <tr>
                  <td style="padding:20px;background:#f9f9fb;border-radius:4px;border:1px solid #eeeeee;">
                    <p style="margin:0;font-size:14px;line-height:1.7;color:#333333;white-space:pre-wrap;">%s</p>
                  </td>
                </tr>
              </table>

              <!-- Reply CTA -->
              <table width="100%%" cellpadding="0" cellspacing="0" style="margin-top:32px;">
                <tr>
                  <td>
                    <a href="mailto:%s"
                      style="display:inline-block;padding:12px 28px;background:linear-gradient(135deg,#58A7E7,#4127EB);color:#ffffff;text-decoration:none;font-size:13px;font-weight:500;border-radius:4px;letter-spacing:0.3px;">
                      Reply to %s
                    </a>
                  </td>
                </tr>
              </table>

            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="padding:20px 40px;background:#f9f9fb;border-top:1px solid #eeeeee;">
              <p style="margin:0;font-size:11px;color:#aaaaaa;text-align:center;">
                This message was sent from the Orbis contact form &mdash; San Pablo City, Philippines
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>`, c.Name, c.Email, c.Message, c.Email, c.Name)

	headers := "MIME-Version: 1.0\r\n" +
		"Content-Type: text/html; charset=\"UTF-8\"\r\n" +
		"Reply-To: " + c.Name + " <" + c.Email + ">\r\n"

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