package main

type MailConfig struct {
	Host     string
	Port     string
	Sender   string
	Password string
	Receiver string
}

var Mail = MailConfig{
	Host:     "smtp.gmail.com",
	Port:     "587",
	Sender:   "internshiptestdomain@gmail.com",
	Password: "awsl qwqe vmyc sltd",
	Receiver: "internshiptestdomain@gmail.com",
}