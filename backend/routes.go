package main

import (
	"github.com/gorilla/mux"
)

func RegisterRoutes(r *mux.Router) {
	// Register, Login, Dashboard, Stats(intern, school, program)
	r.HandleFunc("/register", registerHandler).Methods("POST")
	r.HandleFunc("/login", Login).Methods("POST")
	r.HandleFunc("/dashboard", Dashboard).Methods("GET")
	r.HandleFunc("/new-interns-today", NewInternsToday).Methods("GET")
	r.HandleFunc("/get-stats", GetStats).Methods("GET")
	r.HandleFunc("/school-stats", SchoolStats).Methods("GET")
	r.HandleFunc("/attendance-stats", HandleAttendanceStats(db)).Methods("GET")
	r.HandleFunc("/recent-activity", GetRecentActivity).Methods("GET")

	// Forgot Password
	r.HandleFunc("/forgot-password/send-otp", ForgotPasswordHandler).Methods("POST")
	r.HandleFunc("/forgot-password/verify-otp", VerifyOTPHandler).Methods("POST")
	r.HandleFunc("/forgot-password/reset", ResetPasswordHandler).Methods("POST")

	// Intern CRUD
	r.HandleFunc("/add-intern", AddIntern).Methods("POST")
	r.HandleFunc("/update-intern", UpdateIntern).Methods("PUT")
	r.HandleFunc("/delete-intern", DeleteIntern).Methods("DELETE")
	r.HandleFunc("/verify-otp", VerifyOTP).Methods("POST")
	r.HandleFunc("/contact", ContactHandler).Methods("POST")
	r.HandleFunc("/upload-photo", UploadPhotoHandler).Methods("POST")
	r.HandleFunc("/upload-resume", UploadResumeHandler).Methods("POST")
	r.HandleFunc("/remove-photo", RemovePhotoHandler).Methods("DELETE")
	r.HandleFunc("/remove-resume", RemoveResumeHandler).Methods("DELETE")

	// Intern profile
	r.HandleFunc("/intern", GetInternHandler).Methods("GET")
	r.HandleFunc("/interns", GetInternsHandler).Methods("GET")

	// Admin list
	r.HandleFunc("/admins", GetAdminsHandler).Methods("GET")

	// Intern dashboard
	r.HandleFunc("/intern-dashboard", InternDashboard).Methods("GET")

	// Time logs
	r.HandleFunc("/intern-time-in", InternTimeIn).Methods("POST")
	r.HandleFunc("/intern-time-out", InternTimeOut).Methods("POST")
	r.HandleFunc("/intern-calculate-hours-rendered", InternCalculateHoursRendered).Methods("GET")
	r.HandleFunc("/interns-list", DashboardInternList).Methods("GET")
	r.HandleFunc("/intern-weekly-hours", InternWeeklyHours).Methods("GET")
	r.HandleFunc("/intern-required-hours", InternRequiredHours).Methods("POST")
	r.HandleFunc("/interns/names", InternDropdown).Methods("GET")
	r.HandleFunc("/timelogs/intern", GetTimeLogsForIntern).Methods("GET")
	r.HandleFunc("/intern/timelogs", InternTimeLogs).Methods("GET")
	r.HandleFunc("/intern/timelogs/stats", InternTimeLogStats).Methods("GET")
	r.HandleFunc("/timelogs/overview", TimeLogsOverview).Methods("GET")
	r.HandleFunc("/timelogs/today", TimeLogsToday).Methods("GET")
}