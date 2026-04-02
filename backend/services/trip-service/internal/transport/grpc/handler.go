package grpc

import (
	"context"
	"errors"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
	"io"
	pb "online_taxi/gen/trip-service"
	loggerPkg "online_taxi/services/shared/logger"
	"online_taxi/services/trip-service/internal/app/usecase"
	"online_taxi/services/trip-service/internal/domain"
)

type Handler struct {
	pb.UnimplementedTripServiceServer
	service usecase.Service
	logger  *loggerPkg.Logger
}

func NewHandler(service usecase.Service, logger *loggerPkg.Logger) *Handler {
	return &Handler{
		service: service,
		logger:  logger,
	}
}

func (h *Handler) CreateTrip(ctx context.Context, req *pb.CreateTripRequest) (*pb.TripResponse, error) {
	userID, ok := ctx.Value("userID").(string)
	if !ok || userID == "" {
		return nil, status.Error(codes.Unauthenticated, "неавторизован")
	}

	dto := toCreateDTO(req, userID)

	trip, err := h.service.CreateTrip(ctx, dto)
	if err != nil {
		h.logger.Error("ошибка создания поездки: %v", err)
		return nil, status.Error(codes.Internal, domain.ErrInternal.Error())
	}

	var driverID string
	if trip.DriverID != nil {
		driverID = *trip.DriverID
	}

	return &pb.TripResponse{
		TripId:        trip.ID,
		PassengerId:   trip.PassengerID,
		DriverId:      driverID,
		Status:        parseStatus(trip.Status),
		PickupAddress: trip.PickupAddress,
		DestAddress:   trip.DestAddress,
		PickupLat:     trip.PickupLat,
		PickupLng:     trip.PickupLng,
		DestLat:       trip.DestLat,
		DestLng:       trip.DestLng,
		PriceKzt:      trip.PriceKZT,
	}, nil
}

func (h *Handler) AcceptTrip(ctx context.Context, req *pb.AcceptTripRequest) (*pb.TripResponse, error) {
	userID, ok := ctx.Value("userID").(string)
	if !ok || userID == "" {
		return nil, status.Error(codes.Unauthenticated, "неавторизован")
	}

	dto := toAcceptDTO(req, userID)

	trip, err := h.service.AcceptTrip(ctx, dto)
	if err != nil {
		if errors.Is(err, domain.ErrTripAlreadyAccepted) {
			h.logger.Warn("водитель %s не успел забрать заказ: %v", userID, err)
			return nil, status.Error(codes.AlreadyExists, domain.ErrTripAlreadyAccepted.Error())
		}

		h.logger.Error("ошибка с принятием поездки: %v", err)
		return nil, status.Error(codes.Internal, domain.ErrInternal.Error())
	}

	return &pb.TripResponse{
		TripId:        trip.ID,
		PassengerId:   trip.PassengerID,
		DriverId:      userID,
		Status:        parseStatus(trip.Status),
		PickupAddress: trip.PickupAddress,
		DestAddress:   trip.DestAddress,
		PickupLat:     trip.PickupLat,
		PickupLng:     trip.PickupLng,
		DestLat:       trip.DestLat,
		DestLng:       trip.DestLng,
		PriceKzt:      trip.PriceKZT,
	}, nil
}

func (h *Handler) GetTrip(ctx context.Context, req *pb.GetTripRequest) (*pb.TripResponse, error) {
	trip, err := h.service.GetTrip(ctx, req.TripId)
	if err != nil {
		h.logger.Error("ошибка получения поездки %s: %v", req.TripId, err)
		return nil, status.Error(codes.NotFound, "поездка не найдена")
	}

	var driverID string
	if trip.DriverID != nil {
		driverID = *trip.DriverID
	}

	return &pb.TripResponse{
		TripId:        trip.ID,
		PassengerId:   trip.PassengerID,
		DriverId:      driverID,
		Status:        parseStatus(trip.Status),
		PickupAddress: trip.PickupAddress,
		DestAddress:   trip.DestAddress,
		PickupLat:     trip.PickupLat,
		PickupLng:     trip.PickupLng,
		DestLat:       trip.DestLat,
		DestLng:       trip.DestLng,
		PriceKzt:      trip.PriceKZT,
	}, nil
}

func (h *Handler) SendLocation(stream pb.TripService_SendLocationServer) error {
	driverID, ok := stream.Context().Value("userID").(string)
	if !ok || driverID == "" {
		return status.Error(codes.Unauthenticated, "неавторизован")
	}

	for {
		req, err := stream.Recv() // Ждем новую точку от телефона
		if err != nil {
			// Если водитель сам закрыл стрим (ушел со смены)
			if errors.Is(err, io.EOF) {
				h.logger.Info("стрим водителя %s закрыт", driverID)
				return stream.SendAndClose(&emptypb.Empty{})
			}
			h.logger.Error("ошибка чтения стрима водителя: %v", err)
			return err
		}

		dto := usecase.LocationDTO{
			DriverID: driverID,
			TripID:   req.TripId, // Может быть пустой, если водитель просто на линии
			Lat:      req.Lat,
			Lng:      req.Lng,
		}

		h.service.ProcessLocation(stream.Context(), dto)
	}
}
func (h *Handler) TrackTrip(req *pb.TrackRequest, stream pb.TripService_TrackTripServer) error {
	locChan := h.service.SubscribeToTrip(req.TripId)

	defer h.service.UnsubscribeFromTrip(req.TripId)

	for {
		select {
		case <-stream.Context().Done():
			// Пассажир свернул приложение или у него пропал интернет
			h.logger.Info("пассажир отключился от слежения за поездкой %s", req.TripId)
			return nil // Нормально завершаем работу

		case loc := <-locChan:
			// 1. Пришла новая точка от водителя! Отправляем ее в gRPC-стрим пассажиру
			err := stream.Send(&pb.LocationResponse{
				Lat: loc.Lat,
				Lng: loc.Lng,
			})
			if err != nil {
				h.logger.Error("ошибка отправки координат пассажиру: %v", err)
				return status.Error(codes.Internal, "ошибка отправки данных")
			}
		}
	}
}

func parseStatus(status domain.TripStatus) pb.TripStatus {
	switch status {
	case domain.StatusAccepted:
		return pb.TripStatus_ACCEPTED
	case domain.StatusCancelled:
		return pb.TripStatus_CANCELLED
	case domain.StatusArrived:
		return pb.TripStatus_ARRIVED
	case domain.StatusCompleted:
		return pb.TripStatus_COMPLETED
	case domain.StatusInProgress:
		return pb.TripStatus_IN_PROGRESS
	case domain.StatusSearching:
		return pb.TripStatus_SEARCHING
	default:
		return pb.TripStatus_STATUS_UNSPECIFIED
	}
}
