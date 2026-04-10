package main

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

func main() {
	// Connect to DB
	if err := connectDB(); err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Initialize router
	r := mux.NewRouter()

	// Register ALL routes
	RegisterRoutes(r)

	// Apply CORS middleware
	handler := enableCORS(r)

	log.Println("Server running on http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", handler))
}

// CORS Middleware
func enableCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}