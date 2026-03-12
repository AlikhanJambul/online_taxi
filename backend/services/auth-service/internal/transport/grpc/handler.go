package grpc

import (
	"context"
	"log/slog"
	pb "online_taxi/gen/auth-service"
	"online_taxi/services/auth-service/internal/app/usecase"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// Handler реализует интерфейс gRPC сервера
type Handler struct {
	pb.UnimplementedAuthServiceServer // ОБЯЗАТЕЛЬНО: защита от нереализованных методов
	service                           usecase.Service
}

func NewHandler(s usecase.Service) *Handler {
	return &Handler{service: s}
}

func (h *Handler) Register(ctx context.Context, req *pb.RegisterRequest) (*pb.AuthResponse, error) {
	if req.GetPhone() == "" || req.GetPassword() == "" {
		return nil, status.Error(codes.InvalidArgument, "телефон и пароль обязательны")
	}

	dto := &usecase.RegisterRequest{
		Phone:    req.GetPhone(),
		Password: req.GetPassword(),
		FullName: req.GetFullName(),
		Email:    req.GetEmail(),
		Role:     req.GetRole().String(), // Конвертирую gRPC Enum в строку
		DeviceID: req.GetDeviceId(),
	}

	res, err := h.service.CreateUser(ctx, dto)
	if err != nil {
		slog.Error("error", err)
		return nil, status.Errorf(codes.Internal, "ошибка регистрации: %v", err) // TODO: I need to refactor this. I'll create a function that validates the issue and returns a specific error
	}

	return &pb.AuthResponse{
		AccessToken:  res.AccessToken,
		RefreshToken: res.RefreshToken,
		UserId:       res.UserID,
		Role:         req.GetRole(),
	}, nil
}
