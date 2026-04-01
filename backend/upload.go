package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"time"
)

// Response struct
type UploadResponse struct {
	Message  string `json:"message"`
	FilePath string `json:"file_path"`
}

// UploadHandler handles image upload
func UploadHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid Request Method", http.StatusMethodNotAllowed)
		return
	}

	// Limit upload size (e.g., 5MB)
	err := r.ParseMultipartForm(5 << 20)
	if err != nil {
		http.Error(w, "File too large", http.StatusBadRequest)
		return
	}

	// Get file from form-data (key: "file")
	file, handler, err := r.FormFile("file")
	if err != nil {
		http.Error(w, "Error retrieving file", http.StatusBadRequest)
		return
	}
	defer file.Close()

	// Create uploads folder if not exists
	uploadDir := "uploads"
	err = os.MkdirAll(uploadDir, os.ModePerm)
	if err != nil {
		http.Error(w, "Unable to create folder", http.StatusInternalServerError)
		return
	}

	// Generate unique filename
	ext := filepath.Ext(handler.Filename)
	fileName := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)

	filePath := filepath.Join(uploadDir, fileName)

	// Create file on server
	dst, err := os.Create(filePath)
	if err != nil {
		http.Error(w, "Unable to save file", http.StatusInternalServerError)
		return
	}
	defer dst.Close()

	// Copy uploaded file to destination
	_, err = io.Copy(dst, file)
	if err != nil {
		http.Error(w, "Error saving file", http.StatusInternalServerError)
		return
	}

	// Return response
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(UploadResponse{
		Message:  "File uploaded successfully",
		FilePath: filePath,
	})
}