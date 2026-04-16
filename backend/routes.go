package main

import "github.com/gorilla/mux"

func RegisterRoutes(r *mux.Router) {
	// Register, Login, Dashboard, Stats(intern, school, program)
	r.HandleFunc("/register", registerHandler).Methods("POST")
	r.HandleFunc("/login", Login).Methods("POST")
	r.HandleFunc("/dashboard", Dashboard).Methods("GET")
	r.HandleFunc("/get-stats", GetStats).Methods("GET")
	r.HandleFunc("/school-stats", SchoolStats).Methods("GET")
	r.HandleFunc("/attendance-stats", HandleAttendanceStats(db)).Methods("GET")

	// Intern CRUD
	r.HandleFunc("/add-intern", AddIntern).Methods("POST")
	r.HandleFunc("/update-intern", UpdateIntern).Methods("PUT")
	r.HandleFunc("/delete-intern", DeleteIntern).Methods("DELETE")
	r.HandleFunc("/verify-otp", VerifyOTP).Methods("POST")
	
	// Intern profile
	r.HandleFunc("/intern", GetInternHandler).Methods("GET")

	// Admin list
	r.HandleFunc("/admins", GetAdminsHandler).Methods("GET")

	//time logs
	r.HandleFunc("/intern-time-in", InternTimeIn).Methods("POST")
	r.HandleFunc("/intern-time-out", InternTimeOut).Methods("POST")
	r.HandleFunc("/intern-calculate-hours-rendered", InternCalculateHoursRendered).Methods("GET")
	r.HandleFunc("/interns-list", DashboardInternList).Methods("GET")
	r.HandleFunc("/intern-weekly-hours", InternWeeklyHours).Methods("GET")
	r.HandleFunc("/intern-required-hours", InternRequiredHours).Methods("POST")

}
