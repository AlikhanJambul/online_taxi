package postgres

import (
	"context"
	"errors"
	"fmt"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"online_taxi/services/trip-service/internal/domain"
)

type repository struct {
	db *pgxpool.Pool
}

func NewRepo(db *pgxpool.Pool) domain.Repository {
	return &repository{db: db}
}

func (r *repository) CreateTrip(ctx context.Context, trip *domain.Trip) error {
	query := `
	INSERT INTO trips (
		passenger_id, status, pickup_address, dest_address, 
		pickup_lat, pickup_lng, dest_lat, dest_lng, price_kzt
	) 
	VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	RETURNING id, created_at
`

	err := r.db.QueryRow(ctx, query,
		trip.PassengerID,
		trip.Status, // Сюда передадим domain.StatusSearching
		trip.PickupAddress,
		trip.DestAddress,
		trip.PickupLat,
		trip.PickupLng,
		trip.DestLat,
		trip.DestLng,
		trip.PriceKZT,
	).Scan(&trip.ID, &trip.CreatedAt)

	if err != nil {
		return fmt.Errorf("failed to insert trip: %w", err)
	}

	return nil
}

func (r *repository) AcceptTrip(ctx context.Context, tripID string, driverID string) (*domain.Trip, error) {
	query := `
		UPDATE trips 
		SET 
			driver_id = $1, 
			status = $2, 
			accepted_at = NOW()
		WHERE 
			id = $3 AND status = $4
		RETURNING 
			id, passenger_id, driver_id, status, 
			pickup_address, dest_address, pickup_lat, pickup_lng, 
			dest_lat, dest_lng, price_kzt, created_at, accepted_at
	`

	trip := &domain.Trip{}

	err := r.db.QueryRow(ctx, query,
		driverID,
		domain.StatusAccepted,
		tripID,
		domain.StatusSearching,
	).Scan(
		&trip.ID, &trip.PassengerID, &trip.DriverID, &trip.Status,
		&trip.PickupAddress, &trip.DestAddress, &trip.PickupLat, &trip.PickupLng,
		&trip.DestLat, &trip.DestLng, &trip.PriceKZT, &trip.CreatedAt, &trip.AcceptedAt,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, fmt.Errorf("заказ уже забрали или отменили: %w", domain.ErrTripAlreadyAccepted)
		}
		return nil, fmt.Errorf("ошибка при принятии поездки: %w", err)
	}

	return trip, nil
}

func (r *repository) GetTrip(ctx context.Context, tripID string) (*domain.Trip, error) {
	query := `
		SELECT 
			id, passenger_id, driver_id, status, 
			pickup_address, dest_address, pickup_lat, pickup_lng, 
			dest_lat, dest_lng, price_kzt, created_at, accepted_at, finished_at
		FROM trips 
		WHERE id = $1
	`

	trip := &domain.Trip{}

	err := r.db.QueryRow(ctx, query, tripID).Scan(
		&trip.ID, &trip.PassengerID, &trip.DriverID, &trip.Status,
		&trip.PickupAddress, &trip.DestAddress, &trip.PickupLat, &trip.PickupLng,
		&trip.DestLat, &trip.DestLng, &trip.PriceKZT,
		&trip.CreatedAt, &trip.AcceptedAt, &trip.FinishedAt,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, domain.ErrTripNotFound
		}
		return nil, fmt.Errorf("ошибка БД при получении поездки: %w", err)
	}

	return trip, nil
}

func (r *repository) GetFCMTokens(ctx context.Context, driverIDs []string) ([]string, error) {
	query := `
				SELECT 
				    fcm_token 
				FROM sessions 
				WHERE 
				    user_id = ANY($1) AND fcm_token IS NOT NULL;
`

	rows, err := r.db.Query(ctx, query, driverIDs)
	if err != nil {
		return nil, err
	}

	var tokens []string

	for rows.Next() {
		var token string

		if err := rows.Scan(&token); err != nil {
			return nil, err
		}

		if token != "" {
			tokens = append(tokens, token)
		}
	}

	return tokens, nil
}
