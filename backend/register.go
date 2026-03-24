package main

import (
	"fmt"
	"net/http"
)

func registerHandler(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodPost {
        http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
        return
    }
    // TODO: Read user info from request
    fmt.Fprintf(w, "User registered successfully")
}
