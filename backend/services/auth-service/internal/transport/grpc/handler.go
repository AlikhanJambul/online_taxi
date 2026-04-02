package grpc

import (
	"context"
	"errors"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
	pb "online_taxi/gen/auth-service"
	"online_taxi/services/auth-service/internal/app/usecase"
	"online_taxi/services/auth-service/internal/domain"
	loggerPkg "online_taxi/services/shared/logger"
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

		if errors.Is(err, domain.ErrInvalidEmailOrPassword) {
			h.logger.Warn("проблема со входом: %v", err)
			return nil, status.Errorf(codes.Unauthenticated, domain.ErrInvalidEmailOrPassword.Error())

		}

		h.logger.Error("ошибка при входе: %v", err)
		return nil, status.Error(codes.Internal, domain.ErrInternalError.Error())

	}

	return &pb.AuthResponse{
		AccessToken:  res.AccessToken,
		RefreshToken: res.RefreshToken,
		UserId:       res.UserID,
		Role:         parseRole(res.Role),
	}, nil
}

func (h *Handler) Logout(ctx context.Context, req *pb.LogoutRequest) (*emptypb.Empty, error) {
	if req.GetRefreshToken() == "" {
		return nil, status.Error(codes.InvalidArgument, "токен пустой")
	}

	dto := toLogOutDTO(req)

	err := h.service.ClearSession(ctx, dto)
	if err != nil {

		if errors.Is(err, domain.ErrNilToken) {
			h.logger.Warn("ошибка при удалении токена: %v")
			return nil, status.Error(codes.Unauthenticated, err.Error())
		}

		h.logger.Error("ошибка удаления refresh token: %v", err)
		return nil, status.Error(codes.Internal, err.Error())
	}

	return &emptypb.Empty{}, nil
}

func (h *Handler) Refresh(ctx context.Context, req *pb.RefreshRequest) (*pb.RefreshResponse, error) {
	if req.GetRefreshToken() == "" || req.GetDeviceId() == "" {
		return nil, status.Error(codes.InvalidArgument, "token and device id are required")
	}

	dto := toRefreshDTO(req)

	resp, err := h.service.RefreshToken(ctx, dto)
	if err != nil {

		if errors.Is(err, domain.ErrUserNotFound) {
			h.logger.Warn("ошибка обновления токена: %v", err)
			return nil, status.Error(codes.NotFound, err.Error())
		}

		h.logger.Error("ошибка генерации нового токена: %v", err)
		return nil, status.Error(codes.Internal, domain.ErrInternalError.Error())
	}

	return &pb.RefreshResponse{
		RefreshToken: resp.RefreshToken,
		AccessToken:  resp.AccessToken,
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
