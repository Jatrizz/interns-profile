package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"
)

const uploadDir = "uploads"

// ================= INIT UPLOAD DIRECTORY =================

func initUploadDir() {
	// Get absolute path of working directory
	basePath, err := os.Getwd()
	if err != nil {
		slog.Error("failed to get working directory", "error", err)
		return
	}

	dirPath := filepath.Join(basePath, uploadDir)

	err = os.MkdirAll(dirPath, 0755)
	if err != nil {
		slog.Error("upload directory creation failed",
			"dir", dirPath,
			"error", err,
		)
		return
	}

	slog.Info("upload directory ready", "dir", dirPath)
}

// ================= SAVE FILE =================

func saveUploadedFile(r *http.Request, fieldName string, allowedExts map[string]bool, prefix string) (string, error) {
	file, handler, err := r.FormFile(fieldName)
	if err != nil {
		slog.Debug("no file provided", "field", fieldName)
		return "", nil
	}
	defer file.Close()

	ext := strings.ToLower(filepath.Ext(handler.Filename))
	if !allowedExts[ext] {
		slog.Warn("invalid file type",
			"field", fieldName,
			"filename", handler.Filename,
			"ext", ext,
		)
		return "", fmt.Errorf("invalid file type: %s", ext)
	}

	basePath, err := os.Getwd()
	if err != nil {
		slog.Error("failed to get working directory", "error", err)
		return "", fmt.Errorf("server path error")
	}

	fullDir := filepath.Join(basePath, uploadDir)

	err = os.MkdirAll(fullDir, 0755)
	if err != nil {
		slog.Error("failed to ensure upload directory",
			"dir", fullDir,
			"error", err,
		)
		return "", fmt.Errorf("server storage error")
	}

	fileName := fmt.Sprintf("%s%d%s", prefix, time.Now().UnixNano(), ext)
	filePath := filepath.Join(fullDir, fileName)

	dst, err := os.Create(filePath)
	if err != nil {
		slog.Error("failed to create file",
			"path", filePath,
			"error", err,
		)
		return "", fmt.Errorf("file creation error")
	}
	defer dst.Close()

	size, err := io.Copy(dst, file)
	if err != nil {
		slog.Error("failed to save file",
			"path", filePath,
			"error", err,
		)
		return "", fmt.Errorf("file write error")
	}

	slog.Info("file uploaded",
		"field", fieldName,
		"path", filePath,
		"bytes", size,
	)

	// IMPORTANT: return URL path (not filesystem path)
	return "/" + uploadDir + "/" + fileName, nil
}

// ================= PHOTO UPLOAD =================

func UploadPhotoHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	if err := r.ParseMultipartForm(5 << 20); err != nil {
		slog.Warn("photo upload too large", "error", err)
		http.Error(w, `{"error":"file too large"}`, http.StatusBadRequest)
		return
	}

	userID := r.FormValue("user_id")
	if userID == "" {
		slog.Warn("missing user_id")
		http.Error(w, `{"error":"user_id required"}`, http.StatusBadRequest)
		return
	}

	slog.Info("photo upload started", "user_id", userID)

	photoURL, err := saveUploadedFile(r, "profile_image", map[string]bool{
		".jpg": true, ".jpeg": true, ".png": true,
	}, "photo_")

	if err != nil {
		slog.Error("photo upload failed", "user_id", userID, "error", err)
		http.Error(w, `{"error":"upload failed"}`, http.StatusInternalServerError)
		return
	}

	if photoURL == "" {
		http.Error(w, `{"error":"no file provided"}`, http.StatusBadRequest)
		return
	}

	_, err = db.Exec(`UPDATE users SET photo=$1 WHERE id=$2`, photoURL, userID)
	if err != nil {
		slog.Error("db update failed (photo)",
			"user_id", userID,
			"error", err,
		)
		http.Error(w, `{"error":"database error"}`, http.StatusInternalServerError)
		return
	}

	slog.Info("photo saved to DB", "user_id", userID)

	json.NewEncoder(w).Encode(map[string]string{
		"message":   "photo uploaded",
		"photo_url": photoURL,
	})
}

// ================= RESUME UPLOAD =================

func UploadResumeHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	if err := r.ParseMultipartForm(10 << 20); err != nil {
		slog.Warn("resume upload too large", "error", err)
		http.Error(w, `{"error":"file too large"}`, http.StatusBadRequest)
		return
	}

	userID := r.FormValue("user_id")
	if userID == "" {
		http.Error(w, `{"error":"user_id required"}`, http.StatusBadRequest)
		return
	}

	slog.Info("resume upload started", "user_id", userID)

	resumeURL, err := saveUploadedFile(r, "resume", map[string]bool{
		".pdf": true, ".doc": true, ".docx": true,
		".jpg": true, ".jpeg": true, ".png": true,
	}, "resume_")

	if err != nil {
		slog.Error("resume upload failed", "user_id", userID, "error", err)
		http.Error(w, `{"error":"upload failed"}`, http.StatusInternalServerError)
		return
	}

	if resumeURL == "" {
		http.Error(w, `{"error":"no file provided"}`, http.StatusBadRequest)
		return
	}

	_, err = db.Exec(`UPDATE users SET resume=$1 WHERE id=$2`, resumeURL, userID)
	if err != nil {
		slog.Error("db update failed (resume)",
			"user_id", userID,
			"error", err,
		)
		http.Error(w, `{"error":"database error"}`, http.StatusInternalServerError)
		return
	}

	slog.Info("resume saved to DB", "user_id", userID)

	json.NewEncoder(w).Encode(map[string]string{
		"message":     "resume uploaded",
		"resume_url": resumeURL,
	})
}

func init() {
	initUploadDir()
}