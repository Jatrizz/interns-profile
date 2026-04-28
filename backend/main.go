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
	cwd, _ := os.Getwd()
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
	RegisterRoutes(r)

	handler := enableCORS(r)

	// Use absolute path to avoid any working directory confusion
	http.Handle("/uploads/", enableCORS(
		http.StripPrefix("/uploads/", http.FileServer(http.Dir(filepath.Join(cwd, "uploads")))),
	))

	http.Handle("/", handler)

	log.Println("Server running on http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
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