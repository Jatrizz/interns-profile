package main

type User struct {
	ID          int    `json:"id"`
	InternID    string `json:"intern_id"`
	FirstName   string `json:"first_name"`
	LastName    string `json:"last_name"`
	School      string `json:"school"`
	Program     string `json:"program"`
	Email       string `json:"email"`
	Password    string `json:"password"`
	PhoneNumber string `json:"phone_number"`
	Role        string `json:"role"`
}