package main

import (
	"log"
	"net/http"
	"os"
	"path/filepath"

	"github.com/gorilla/mux"
)

func main() {
	// Debug: print working directory and uploads contents
	cwd, err := os.Getwd()
	if err != nil {
		log.Fatal("Failed to get working directory:", err)
	}

	log.Println("Working directory:", cwd)
	log.Println("Uploads path:", filepath.Join(cwd, "uploads"))

	files, err := os.ReadDir(filepath.Join(cwd, "uploads"))
	if err != nil {
		log.Println("ERROR reading uploads dir:", err)
	} else {
		for _, f := range files {
			log.Println("Found file:", f.Name())
		}
	}

	// Connect DB
	if err := connectDB(); err != nil {
		log.Fatal("DB connection failed:", err)
	}

	c := StartAttendanceCron()
	defer c.Stop()

	r := mux.NewRouter()
	// API Routes
	RegisterRoutes(r)

	r.PathPrefix("/uploads/").Handler(
		http.StripPrefix("/uploads/",
			http.FileServer(http.Dir(filepath.Join(cwd, "uploads"))),
		),
	)

	handler := enableCORS(r)

	log.Println("Server running on http://localhost:8080")

	err = http.ListenAndServe(":8080", handler)
	if err != nil {
		log.Fatal("Server failed:", err)
	}
}

// CORS Middleware
func enableCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		allowedOrigins := []string{
			"http://localhost:3000",
			"http://localhost:8080",
		}

		origin := r.Header.Get("Origin")

		// Check if request origin is in our allowed list
		for _, o := range allowedOrigins {
			if o == origin {
				w.Header().Set("Access-Control-Allow-Origin", origin)
				break
			}
		}

		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}
