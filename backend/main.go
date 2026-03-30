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

	r.HandleFunc("/register", registerHandler).Methods("POST")
	r.HandleFunc("/login", Login).Methods("POST")
	r.HandleFunc("/dashboard", Dashboard).Methods("GET")
	r.HandleFunc("/add-student", AddStudent).Methods("POST")
	/*r.HandleFunc("/delete-student", Deletestudent).Methods("DELETE") */

	log.Println("Server running on :8080")
	err = http.ListenAndServe(":8080", r)
	if err != nil {
		log.Fatal("Server error:", err)
	}
}
