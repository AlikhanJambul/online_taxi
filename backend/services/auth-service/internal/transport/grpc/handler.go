package grpc

import (
	"context"
	"errors"
	pb "online_taxi/gen/auth-service"
	"online_taxi/services/auth-service/internal/app/usecase"
	"online_taxi/services/auth-service/internal/domain"
	loggerPkg "online_taxi/services/pkg/logger"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type Handler struct {
	pb.UnimplementedAuthServiceServer // ОБЯЗАТЕЛЬНО: защита от нереализованных методов
	service                           usecase.Service
	logger                            *loggerPkg.Logger
}

func NewHandler(s usecase.Service, logger *loggerPkg.Logger) *Handler {
	return &Handler{service: s, logger: logger}
}

func (h *Handler) Register(ctx context.Context, req *pb.RegisterRequest) (*pb.AuthResponse, error) {
	if req.GetPhone() == "" || req.GetPassword() == "" {
		return nil, status.Error(codes.InvalidArgument, "телефон и пароль обязательны")
	}

	dto := toRegisterDTO(req)

	res, err := h.service.CreateUser(ctx, dto)
	if err != nil {
		h.logger.Error("ошибка при регистрации: %v", err)
		return nil, status.Error(codes.Internal, domain.ErrInternalError.Error())
	}

	return &pb.AuthResponse{
		AccessToken:  res.AccessToken,
		RefreshToken: res.RefreshToken,
		UserId:       res.UserID,
		Role:         req.GetRole(),
	}, nil
}

func (h *Handler) Login(ctx context.Context, req *pb.LoginRequest) (*pb.AuthResponse, error) {
	if req.GetEmail() == "" || req.GetPassword() == "" {
		return nil, status.Error(codes.InvalidArgument, "почта и пароль обязательны")
	}

	dto := toLogInDTO(req)

	res, err := h.service.SaveSession(ctx, dto)
	if err != nil {
		h.logger.Error("ошибка при входе: %v", err)

		if errors.Is(err, domain.ErrInvalidEmailOrPassword) {
			return nil, status.Errorf(codes.Unauthenticated, domain.ErrInvalidEmailOrPassword.Error())

		}

		return nil, status.Error(codes.Internal, domain.ErrInternalError.Error())

	}

	return &pb.AuthResponse{
		AccessToken:  res.AccessToken,
		RefreshToken: res.RefreshToken,
		UserId:       res.UserID,
		Role:         parseRole(res.Role),
	}, nil
}

func parseRole(role string) pb.Role {
	switch role {
	case "PASSENGER":
		return pb.Role_PASSENGER
	case "DRIVER":
		return pb.Role_DRIVER
	case "ADMIN":
		return pb.Role_ADMIN
	default:
		return pb.Role_ROLE_UNSPECIFIED
	}
}
