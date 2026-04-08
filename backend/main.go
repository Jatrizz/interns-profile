package main

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

func main() {
	if err := connectDB(); err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	r := mux.NewRouter()

	// Register route
	r.HandleFunc("/register", registerHandler).Methods("POST", "OPTIONS")

	// Apply CORS
	handler := enableCORS(r)

	log.Println("Server running on :8080")
	log.Fatal(http.ListenAndServe(":8080", handler))
}

func enableCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		w.Header().Set("Access-Control-Allow-Credentials", "true")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}