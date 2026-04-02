package usecase

import (
	"context"
	"fmt"
	loggerPkg "online_taxi/services/shared/logger"
	queue "online_taxi/services/trip-service/internal/adapters/rmq"
	"online_taxi/services/trip-service/internal/domain"
	"sync"
)

type Service interface {
	CreateTrip(ctx context.Context, dto CreateTripDTO) (*domain.Trip, error)
	AcceptTrip(ctx context.Context, dto AcceptTripDTO) (*domain.Trip, error)
	GetTrip(ctx context.Context, tripID string) (*domain.Trip, error)

	ProcessLocation(ctx context.Context, loc LocationDTO)
	SubscribeToTrip(tripID string) <-chan LocationDTO
	UnsubscribeFromTrip(tripID string)
}

type service struct {
	repo   domain.Repository
	rmq    *queue.RabbitPublisher
	redis  domain.DriverLocationRepository
	logger *loggerPkg.Logger

	activeStreams map[string]chan LocationDTO
	mu            sync.RWMutex
}

func NewService(
	repo domain.Repository,
	rmq *queue.RabbitPublisher,
	redis domain.DriverLocationRepository,
	logger *loggerPkg.Logger,
) Service {
	return &service{
		repo:          repo,
		rmq:           rmq,
		redis:         redis,
		logger:        logger,
		activeStreams: make(map[string]chan LocationDTO),
	}
}

func (u *service) CreateTrip(ctx context.Context, dto CreateTripDTO) (*domain.Trip, error) {
	trip := &domain.Trip{
		PassengerID:   dto.PassengerID,
		PickupAddress: dto.PickupAddress,
		DestAddress:   dto.DestAddress,
		PickupLat:     dto.PickupLat,
		PickupLng:     dto.PickupLng,
		DestLat:       dto.DestLat,
		DestLng:       dto.DestLng,
		PriceKZT:      dto.PriceKZT,

		Status: domain.StatusSearching,
	}

	err := u.repo.CreateTrip(ctx, trip)
	if err != nil {
		return nil, fmt.Errorf("usecase - failed to create trip: %w", err)
	}

	err = u.rmq.Publish("trip.events", "trip.created", trip)
	if err != nil {
		fmt.Printf("WARNING: failed to publish trip.created event: %v\n", err)
	}

	return trip, nil
}

func (s *service) AcceptTrip(ctx context.Context, dto AcceptTripDTO) (*domain.Trip, error) {
	trip, err := s.repo.AcceptTrip(ctx, dto.TripID, dto.DriverID)
	if err != nil {
		return nil, err
	}

	err = s.rmq.Publish("trip.events", "trip.status.changed", trip)
	if err != nil {
		fmt.Printf("WARNING: failed to publish trip.status.changed event: %v\n", err)
	}
	return trip, nil
}

func (s *service) GetTrip(ctx context.Context, tripID string) (*domain.Trip, error) {
	trip, err := s.repo.GetTrip(ctx, tripID)
	if err != nil {
		return nil, err
	}
	return trip, nil
}

// SubscribeToTrip создает канал для пассажира
func (s *service) SubscribeToTrip(tripID string) <-chan LocationDTO {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Создаем буферизированный канал (чтобы водитель не блокировался)
	ch := make(chan LocationDTO, 10)
	s.activeStreams[tripID] = ch
	return ch
}

// UnsubscribeFromTrip удаляет канал, когда пассажир ушел
func (s *service) UnsubscribeFromTrip(tripID string) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if ch, exists := s.activeStreams[tripID]; exists {
		close(ch)
		delete(s.activeStreams, tripID)
	}
}

// ProcessLocation получает точку от водителя и пересылает пассажиру
func (s *service) ProcessLocation(ctx context.Context, loc LocationDTO) {
	// Если водитель просто на линии (trip_id пустой), тут позже будем писать в Redis GEO
	if loc.TripID == "" {
		err := s.redis.UpdateLocation(ctx, loc.DriverID, loc.Lat, loc.Lng)
		if err != nil {
			s.logger.Warn("failed to update driver %s location: %v", loc.DriverID, err)
		}

		return
	}

	// Если водитель в поездке, ищем канал пассажира
	s.mu.RLock()
	ch, exists := s.activeStreams[loc.TripID]
	s.mu.RUnlock()

	if exists {
		// Неблокирующая отправка в канал пассажира
		select {
		case ch <- loc:
			// Успешно отправлено пассажиру!
		default:
			// Канал забит (пассажир не успевает читать), пропускаем точку,
			// чтобы водитель не завис. Это нормально для GPS трекинга.
		}
	}

	err := s.rmq.Publish("location.events", "location.trip_track", loc)
	if err != nil {
		fmt.Printf("WARNING: failed to publish location to history: %v\n", err)
	}
}
