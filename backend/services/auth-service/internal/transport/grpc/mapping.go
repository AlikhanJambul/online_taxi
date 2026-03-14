package grpc

import (
	pb "online_taxi/gen/auth-service"
	"online_taxi/services/auth-service/internal/app/usecase"
)

func toRegisterDTO(req *pb.RegisterRequest) *usecase.RegisterRequestDTO {
	return &usecase.RegisterRequestDTO{
		Phone:    req.GetPhone(),
		Password: req.GetPassword(),
		FullName: req.GetFullName(),
		Email:    req.GetEmail(),
		Role:     req.GetRole().String(), // Конвертирую gRPC Enum в строку
		DeviceID: req.GetDeviceId(),
	}
}

func toLogInDTO(req *pb.LoginRequest) *usecase.LoginRequestDTO {
	return &usecase.LoginRequestDTO{
		Password: req.GetPassword(),
		Email:    req.GetEmail(),
		DeviceID: req.GetDeviceId(),
	}
}
