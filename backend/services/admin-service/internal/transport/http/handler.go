package http

import (
	"encoding/json"
	"net/http"
	"online_taxi/services/admin-service/internal/app/usecase"
	"online_taxi/services/admin-service/internal/domain"
	loggerPkg "online_taxi/services/shared/logger"
	"online_taxi/services/shared/jwt"
)

type Handler struct {
	service usecase.Service
	logger  *loggerPkg.Logger
	tm      *jwt.TokenManager
}

func NewHandler(service usecase.Service, logger *loggerPkg.Logger, tm *jwt.TokenManager) *Handler {
	return &Handler{service: service, logger: logger, tm: tm}
}

func (h *Handler) Route() http.Handler {
	mux := http.NewServeMux()

	mux.HandleFunc("GET /api/v1/admin/users", h.GetUsers)
	mux.HandleFunc("POST /api/v1/admin/drivers/accept", h.AcceptDriver)
	mux.HandleFunc("GET /api/v1/admin/drivers", h.GetDrivers)

	return AdminAuthMiddleware(h.tm, mux)
}

func (h *Handler) GetUsers(w http.ResponseWriter, r *http.Request) {
	users, err := h.service.GetUsers(r.Context())
	if err != nil {
		h.logger.Warn("ошибка получения пользователей: %v", err)
		ErrJsonResponse(w, err)
		return
	}

	JsonResponse(w, 200, users)
}

func (h *Handler) AcceptDriver(w http.ResponseWriter, r *http.Request) {
	var req usecase.AcceptDriverDTO

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.logger.Warn("ошибка при декодировании запроса в структуру: %v", err)
		ErrJsonResponse(w, domain.ErrInternal)
		return
	}

	err := h.service.AcceptDriver(r.Context(), req)
	if err != nil {
		h.logger.Warn("ошибка изменения статуса водителя id:%s. Ошибка: %v", req.ID, err)
		ErrJsonResponse(w, err)
		return
	}

	JsonResponse(w, 200, "статус изменён!")
}

func (h *Handler) GetDrivers(w http.ResponseWriter, r *http.Request) {
	drivers, err := h.service.GetDrivers(r.Context())
	if err != nil {
		h.logger.Warn("ошибка получения водителей: %v", err)
		ErrJsonResponse(w, err)
		return
	}

	JsonResponse(w, 200, drivers)
}
