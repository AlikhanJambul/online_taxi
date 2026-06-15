package usecase

import (
	"context"
	"fmt"
	loggerPkg "online_taxi/services/shared/logger"
	queue "online_taxi/services/trip-service/internal/adapters/rmq"
	"online_taxi/services/trip-service/internal/domain"
	"strconv"
	"sync"
)

type Service interface {
	CreateTrip(ctx context.Context, dto CreateTripDTO) (*domain.Trip, error)
	AcceptTrip(ctx context.Context, dto AcceptTripDTO) (*domain.Trip, error)
	GetTrip(ctx context.Context, tripID string) (*domain.Trip, error)
	EstimatePrice(dto EstimatePriceReqDTO) domain.PriceEstimate

	DriverArrived(ctx context.Context, tripID, driverID string) (*domain.Trip, error)
	StartTrip(ctx context.Context, tripID, driverID string) (*domain.Trip, error)
	CompleteTrip(ctx context.Context, tripID, driverID string) (*domain.Trip, error)
	CancelTrip(ctx context.Context, tripID, userID string) (*domain.Trip, error)

	NotifyTripStatusChange(ctx context.Context, trip *domain.Trip) error

	ProcessLocation(ctx context.Context, loc LocationDTO)
	SubscribeToTrip(tripID string) <-chan LocationDTO
	UnsubscribeFromTrip(tripID string)

	FindAndNotifyDrivers(ctx context.Context, trip *domain.Trip) error
	SubmitReview(ctx context.Context, tripID, passengerID string, score int) error
	GetTripHistory(ctx context.Context, passengerID string) ([]domain.TripHistoryItem, error)
}

type service struct {
	repo   domain.Repository
	rmq    *queue.RabbitPublisher
	redis  domain.DriverLocationRepository
	notify domain.Notification
	logger *loggerPkg.Logger

	activeStreams map[string]chan LocationDTO
	mu            sync.RWMutex
}

func NewService(
	repo domain.Repository,
	rmq *queue.RabbitPublisher,
	redis domain.DriverLocationRepository,
	notify domain.Notification,
	logger *loggerPkg.Logger,
) Service {
	return &service{
		repo:          repo,
		rmq:           rmq,
		redis:         redis,
		notify:        notify,
		logger:        logger,
		activeStreams: make(map[string]chan LocationDTO),
	}
}

func (s *service) CreateTrip(ctx context.Context, dto CreateTripDTO) (*domain.Trip, error) {
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

	err := s.repo.CreateTrip(ctx, trip)
	if err != nil {
		return nil, fmt.Errorf("usecase - failed to create trip: %w", err)
	}

	err = s.rmq.Publish("trip.events", "trip.created", trip)
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

func (s *service) FindAndNotifyDrivers(ctx context.Context, trip *domain.Trip) error {
	// 1. REDIS: Search for drivers within a 5 km radius
	driverIDs, err := s.redis.FindNearest(ctx, trip.PickupLat, trip.PickupLng, 5.0)
	if err != nil {
		return fmt.Errorf("usecase - ошибка гео-поиска в Redis: %w", err)
	}

	if len(driverIDs) == 0 {
		s.logger.Info("Для заказа %s нет свободных водителей рядом", trip.ID)
		return nil // there's no error, just not found.
		// (In real Uber, they start a timer and search again after 10 seconds)
	}

	// 2. POSTGRES: Get FCM tokens
	tokens, err := s.repo.GetFCMTokens(ctx, driverIDs)
	if err != nil {
		return fmt.Errorf("usecase - ошибка получения fcm токенов: %w", err)
	}

	if len(tokens) == 0 {
		s.logger.Info("Водители рядом есть, но у них нет fcm-токенов (не залогинены)")
		return nil
	}

	// 3. GOOGLE (Firebase): send push-notification
	s.logger.Info("🔥 УСПЕХ: Отправляем Push-уведомления %d водителям для заказа %s", len(tokens), trip.ID)
	response := domain.NotifyNewTrip(trip.ID)

	estimate := domain.CalculatePrice(trip.PickupLat, trip.PickupLng, trip.DestLat, trip.DestLng)

	data := map[string]string{
		"type":           "new_trip",
		"trip_id":        trip.ID,
		"pickup_address": trip.PickupAddress,
		"dest_address":   trip.DestAddress,
		"pickup_lat":     strconv.FormatFloat(trip.PickupLat, 'f', 6, 64),
		"pickup_lng":     strconv.FormatFloat(trip.PickupLng, 'f', 6, 64),
		"dest_lat":       strconv.FormatFloat(trip.DestLat, 'f', 6, 64),
		"dest_lng":       strconv.FormatFloat(trip.DestLng, 'f', 6, 64),
		"price_kzt":      strconv.FormatInt(trip.PriceKZT, 10),
		"distance_km":    strconv.FormatFloat(estimate.DistanceKm, 'f', 2, 64),
	}
	deadTokens, err := s.notify.SendPushMulti(ctx, tokens, response.Title, response.Body, data)
	if err != nil {
		return err
	}

	if len(deadTokens) > 0 {
		if delErr := s.repo.DeleteFCMTokens(ctx, deadTokens); delErr != nil {
			s.logger.Warn("failed to delete dead FCM tokens: %v", delErr)
		}
	}

	return nil
}

func (s *service) DriverArrived(ctx context.Context, tripID, driverID string) (*domain.Trip, error) {
	trip, err := s.repo.DriverArrived(ctx, tripID, driverID)
	if err != nil {
		return nil, err
	}

	if pubErr := s.rmq.Publish("trip.events", "trip.status.changed", trip); pubErr != nil {
		s.logger.Warn("failed to publish trip.status.changed (arrived): %v", pubErr)
	}
	return trip, nil
}

func (s *service) StartTrip(ctx context.Context, tripID, driverID string) (*domain.Trip, error) {
	trip, err := s.repo.StartTrip(ctx, tripID, driverID)
	if err != nil {
		return nil, err
	}

	if pubErr := s.rmq.Publish("trip.events", "trip.status.changed", trip); pubErr != nil {
		s.logger.Warn("failed to publish trip.status.changed (in_progress): %v", pubErr)
	}
	return trip, nil
}

func (s *service) CompleteTrip(ctx context.Context, tripID, driverID string) (*domain.Trip, error) {
	trip, err := s.repo.CompleteTrip(ctx, tripID, driverID)
	if err != nil {
		return nil, err
	}

	// trip.status.changed → notification.push (уведомление пассажиру)
	if pubErr := s.rmq.Publish("trip.events", "trip.status.changed", trip); pubErr != nil {
		s.logger.Warn("failed to publish trip.status.changed (completed): %v", pubErr)
	}
	// trip.completed → billing + rating в отдельных консьюмерах
	if pubErr := s.rmq.Publish("trip.events", "trip.completed", trip); pubErr != nil {
		s.logger.Warn("failed to publish trip.completed: %v", pubErr)
	}
	return trip, nil
}

func (s *service) CancelTrip(ctx context.Context, tripID, userID string) (*domain.Trip, error) {
	trip, err := s.repo.CancelTrip(ctx, tripID, userID)
	if err != nil {
		return nil, err
	}

	if pubErr := s.rmq.Publish("trip.events", "trip.status.changed", trip); pubErr != nil {
		s.logger.Warn("failed to publish trip.status.changed (cancelled): %v", pubErr)
	}
	return trip, nil
}

func (s *service) NotifyTripStatusChange(ctx context.Context, trip *domain.Trip) error {
	tokens, err := s.repo.GetFCMTokens(ctx, []string{trip.PassengerID})
	if err != nil {
		return fmt.Errorf("failed to get passenger FCM tokens: %w", err)
	}
	if len(tokens) == 0 {
		s.logger.Info("пассажир %s не имеет FCM-токена, пропускаем уведомление", trip.PassengerID)
		return nil
	}

	notif := domain.NotifyByStatus(trip.Status)
	if notif.Title == "" {
		return nil
	}

	statusData := map[string]string{
		"type":    "status_changed",
		"trip_id": trip.ID,
		"status":  string(trip.Status),
	}
	deadTokens, err := s.notify.SendPushMulti(ctx, tokens, notif.Title, notif.Body, statusData)
	if err != nil {
		return fmt.Errorf("failed to send push to passenger: %w", err)
	}

	if len(deadTokens) > 0 {
		if delErr := s.repo.DeleteFCMTokens(ctx, deadTokens); delErr != nil {
			s.logger.Warn("failed to delete dead passenger FCM tokens: %v", delErr)
		}
	}

	return nil
}

func (s *service) GetTripHistory(ctx context.Context, passengerID string) ([]domain.TripHistoryItem, error) {
	return s.repo.GetTripHistory(ctx, passengerID)
}

func (s *service) SubmitReview(ctx context.Context, tripID, passengerID string, score int) error {
	trip, err := s.repo.GetTrip(ctx, tripID)
	if err != nil {
		return fmt.Errorf("поездка не найдена: %w", err)
	}
	if trip.Status != domain.StatusCompleted {
		return fmt.Errorf("можно оставить отзыв только для завершённой поездки")
	}
	if trip.DriverID == nil {
		return fmt.Errorf("у поездки нет водителя")
	}
	return s.repo.SaveReview(ctx, tripID, passengerID, *trip.DriverID, score)
}

func (s *service) EstimatePrice(dto EstimatePriceReqDTO) domain.PriceEstimate {
	return domain.CalculatePrice(dto.PickupLat, dto.PickupLng, dto.DestLat, dto.DestLng)
}
