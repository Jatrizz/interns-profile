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

	RegisterRoutes(r) 

	log.Println("Server running on :8080")
	http.ListenAndServe(":8080", r)
}
