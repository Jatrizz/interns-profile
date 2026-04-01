package main

import "github.com/gorilla/mux"

func RegisterRoutes(r *mux.Router) {
	// Register, Login, Dashboard
	r.HandleFunc("/register", registerHandler).Methods("POST")
	r.HandleFunc("/login", Login).Methods("POST")
	r.HandleFunc("/dashboard", Dashboard).Methods("GET")

	// Intern CRUD
	r.HandleFunc("/add-student", AddStudent).Methods("POST")
	r.HandleFunc("/update-student", Updatestudent).Methods("PUT")
	r.HandleFunc("/delete-student", Deletestudent).Methods("DELETE")

	// Intern profile
	r.HandleFunc("/intern", GetInternHandler).Methods("GET")

	// Admin list
	r.HandleFunc("/admins", GetAdminsHandler).Methods("GET")
}