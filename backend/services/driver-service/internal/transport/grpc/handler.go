package grpc

import (
	"context"
	"errors"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
	pb "online_taxi/gen/driver-service"
	"online_taxi/services/driver-service/internal/app/usecase"
	"online_taxi/services/driver-service/internal/domain"
	loggerPkg "online_taxi/services/shared/logger"
	"time"
)

type Handler struct {
	pb.UnimplementedDriverServiceServer
	service usecase.Service
	logger  *loggerPkg.Logger
}

func NewHandler(service usecase.Service, logger *loggerPkg.Logger) *Handler {
	return &Handler{
		service: service,
		logger:  logger,
	}
}

func (h *Handler) CreateProfile(ctx context.Context, req *pb.CreateProfileRequest) (*pb.DriverProfileResponse, error) {
	dto := toCreateDTO(req)

	resp, err := h.service.CreateDriver(ctx, dto)
	if err != nil {
		h.logger.Error("ошибка создания водителя: %v", err)

		return nil, status.Error(codes.Internal, domain.ErrInternal.Error())
	}

	return &pb.DriverProfileResponse{
		UserId:       resp.UserID,
		CarMake:      resp.CarMake,
		CarModel:     resp.CarModel,
		CarColor:     resp.CarColor,
		LicensePlate: resp.LicensePlate,
		Status:       parseStatus(resp.Status),
	}, nil
}

func (h *Handler) GetProfile(ctx context.Context, req *emptypb.Empty) (*pb.DriverProfileResponse, error) {
	resp, err := h.service.GetDriver(ctx)
	if err != nil {

		if errors.Is(err, domain.ErrDriverNotFound) {
			h.logger.Warn("водитель не смог получить профиль: %v", err)
			return nil, status.Error(codes.NotFound, err.Error())
		}

		h.logger.Error("ошибка получения профиля: %v", err)
		return nil, status.Error(codes.Internal, domain.ErrInternal.Error())
	}

	return &pb.DriverProfileResponse{
		UserId:       resp.UserID,
		CarMake:      resp.CarMake,
		CarModel:     resp.CarModel,
		CarColor:     resp.CarColor,
		LicensePlate: resp.LicensePlate,
		Status:       parseStatus(resp.Status),
	}, nil
}

func (h *Handler) GetCarUploadURL(ctx context.Context, req *emptypb.Empty) (*pb.GetUploadURLResponse, error) {
	id, ok := ctx.Value("userID").(string)
	if !ok || id == "" {
		h.logger.Warn("пользователь не авторизован")
		return nil, status.Error(codes.Unauthenticated, domain.ErrUnauth.Error())
	}

	uploadURL, fileURL, err := h.service.GetCarUploadURL(ctx, time.Minute*15)
	if err != nil {
		h.logger.Warn("ошибка с получением ссылки: %v", err)
		return nil, status.Error(codes.Internal, domain.ErrInternal.Error())
	}

	return &pb.GetUploadURLResponse{
		UploadUrl: uploadURL,
		FileUrl:   fileURL,
	}, nil
}

func parseStatus(status string) pb.DriverStatus {
	switch status {
	case "PENDING":
		return pb.DriverStatus_PENDING
	case "APPROVED":
		return pb.DriverStatus_APPROVED
	case "REJECTED":
		return pb.DriverStatus_REJECTED
	default:
		return pb.DriverStatus_STATUS_UNSPECIFIED
	}
}
