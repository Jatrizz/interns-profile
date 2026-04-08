package main

import (
    "encoding/json"
    "net/http"
    "strings"

    "golang.org/x/crypto/bcrypt"
)

type User struct {
    ID          int    `json:"id"`
    FirstName   string `json:"first_name"`
    LastName    string `json:"last_name"`
    School      string `json:"school"`
    Program     string `json:"program"`
    Email       string `json:"email"`
    Password    string `json:"password"`
    PhoneNumber string `json:"phone_number"`
}

func registerHandler(w http.ResponseWriter, r *http.Request) {
    if r.Method == http.MethodOptions {
        w.WriteHeader(http.StatusOK)
        return
    }

    w.Header().Set("Content-Type", "application/json")

    var user User
    if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
        w.WriteHeader(http.StatusBadRequest)
        json.NewEncoder(w).Encode(map[string]string{"error": "Invalid request body"})
        return
    }

    errors := map[string]string{}

    if strings.TrimSpace(user.FirstName) == "" {
        errors["first_name"] = "First name is required"
    }
    if strings.TrimSpace(user.LastName) == "" {
        errors["last_name"] = "Last name is required"
    }
    if strings.TrimSpace(user.School) == "" {
        errors["school"] = "School is required"
    }
    if strings.TrimSpace(user.Program) == "" {
        errors["program"] = "Program is required"
    }
    if strings.TrimSpace(user.Email) == "" {
        errors["email"] = "Email is required"
    } else if !strings.Contains(user.Email, "@") {
        errors["email"] = "Invalid email format"
    }
    if strings.TrimSpace(user.Password) == "" {
        errors["password"] = "Password is required"
    } else if len(user.Password) < 8 {
        errors["password"] = "Password must be at least 8 characters"
    }

    if len(errors) > 0 {
        w.WriteHeader(http.StatusBadRequest)
        json.NewEncoder(w).Encode(map[string]interface{}{"errors": errors})
        return
    }

    // Check duplicate
    var exists bool
    err := db.QueryRow("SELECT EXISTS(SELECT 1 FROM interns WHERE email=$1)", user.Email).Scan(&exists)
    if err != nil {
        w.WriteHeader(http.StatusInternalServerError)
        json.NewEncoder(w).Encode(map[string]string{"error": "Database error"})
        return
    }
    if exists {
        errors["email"] = "Email already registered"
        w.WriteHeader(http.StatusConflict)
        json.NewEncoder(w).Encode(map[string]interface{}{"errors": errors})
        return
    }

    // Hash password
    hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
    if err != nil {
        w.WriteHeader(http.StatusInternalServerError)
        json.NewEncoder(w).Encode(map[string]string{"error": "Password hashing failed"})
        return
    }

    _, err = db.Exec(`
        INSERT INTO interns (first_name, last_name, school, program, email, password_hash, phone_number)
        VALUES ($1,$2,$3,$4,$5,$6,$7)`,
        user.FirstName, user.LastName, user.School, user.Program,
        user.Email, string(hashedPassword), user.PhoneNumber,
    )
    if err != nil {
        w.WriteHeader(http.StatusInternalServerError)
        json.NewEncoder(w).Encode(map[string]string{"error": "Failed to save user"})
        return
    }

    json.NewEncoder(w).Encode(map[string]string{"message": "User registered successfully"})
}