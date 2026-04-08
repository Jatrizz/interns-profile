package main

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

func main() {
	// Connect to database
	err := connectDB()
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Create router
	r := mux.NewRouter()

	// Register all routes
	RegisterRoutes(r)

	// Apply CORS middleware
	handler := enableCORS(r)

	log.Println("Server running on :8080")

	err = http.ListenAndServe(":8080", handler)
	if err != nil {
		log.Fatal(err)
	}
}

// ✅ Improved CORS middleware
func enableCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		// Allow all origins (for development)
		w.Header().Set("Access-Control-Allow-Origin", "*")

		// Allow methods
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")

		// Allow headers (IMPORTANT: include more headers)
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		// Allow credentials (optional, safe to include)
		w.Header().Set("Access-Control-Allow-Credentials", "true")

		// Handle preflight request properly
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}