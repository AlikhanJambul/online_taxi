package http

import (
	"encoding/json"
	"errors"
	"net/http"
	"online_taxi/services/admin-service/internal/domain"
)

func JsonResponse(w http.ResponseWriter, statusCode int, object interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status": statusCode,
		"body":   object,
	})
}

func ErrJsonResponse(w http.ResponseWriter, err error) {
	statusCode, err := CheckCode(err)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	json.NewEncoder(w).Encode(map[string]string{"error": err.Error()})
}

func CheckCode(err error) (int, error) {
	if errors.Is(err, domain.ErrNotFound) {
		return 404, err
	}

	return 500, domain.ErrInternal
}
