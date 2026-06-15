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
			t.id, t.passenger_id, t.driver_id, t.status,
			t.pickup_address, t.dest_address, t.pickup_lat, t.pickup_lng,
			t.dest_lat, t.dest_lng, t.price_kzt, t.created_at, t.accepted_at, t.finished_at,
			COALESCE(dp.car_make, ''), COALESCE(dp.car_model, ''),
			COALESCE(dp.car_color, ''), COALESCE(dp.license_plate, ''),
			COALESCE(u.avatar_url, '')
		FROM trips t
		LEFT JOIN driver_profiles dp ON dp.user_id = t.driver_id
		LEFT JOIN users u ON u.id = t.driver_id
		WHERE t.id = $1
	`

	trip := &domain.Trip{}

	err := r.db.QueryRow(ctx, query, tripID).Scan(
		&trip.ID, &trip.PassengerID, &trip.DriverID, &trip.Status,
		&trip.PickupAddress, &trip.DestAddress, &trip.PickupLat, &trip.PickupLng,
		&trip.DestLat, &trip.DestLng, &trip.PriceKZT,
		&trip.CreatedAt, &trip.AcceptedAt, &trip.FinishedAt,
		&trip.CarMake, &trip.CarModel, &trip.CarColor, &trip.LicensePlate,
		&trip.DriverAvatarURL,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, domain.ErrTripNotFound
		}
		return nil, fmt.Errorf("ошибка БД при получении поездки: %w", err)
	}

	return trip, nil
}

func (r *repository) DriverArrived(ctx context.Context, tripID, driverID string) (*domain.Trip, error) {
	query := `
		UPDATE trips SET status = $1
		WHERE id = $2 AND driver_id = $3 AND status = $4
		RETURNING id, passenger_id, driver_id, status,
		          pickup_address, dest_address, pickup_lat, pickup_lng,
		          dest_lat, dest_lng, price_kzt, created_at, accepted_at, finished_at
	`
	row := r.db.QueryRow(ctx, query,
		domain.StatusArrived, tripID, driverID, domain.StatusAccepted,
	)
	return scanTrip(row)
}

func (r *repository) StartTrip(ctx context.Context, tripID, driverID string) (*domain.Trip, error) {
	query := `
		UPDATE trips SET status = $1
		WHERE id = $2 AND driver_id = $3 AND status = $4
		RETURNING id, passenger_id, driver_id, status,
		          pickup_address, dest_address, pickup_lat, pickup_lng,
		          dest_lat, dest_lng, price_kzt, created_at, accepted_at, finished_at
	`
	row := r.db.QueryRow(ctx, query,
		domain.StatusInProgress, tripID, driverID, domain.StatusArrived,
	)
	return scanTrip(row)
}

func (r *repository) CompleteTrip(ctx context.Context, tripID, driverID string) (*domain.Trip, error) {
	query := `
		UPDATE trips SET status = $1, finished_at = NOW()
		WHERE id = $2 AND driver_id = $3 AND status = $4
		RETURNING id, passenger_id, driver_id, status,
		          pickup_address, dest_address, pickup_lat, pickup_lng,
		          dest_lat, dest_lng, price_kzt, created_at, accepted_at, finished_at
	`
	row := r.db.QueryRow(ctx, query,
		domain.StatusCompleted, tripID, driverID, domain.StatusInProgress,
	)
	return scanTrip(row)
}

func (r *repository) CancelTrip(ctx context.Context, tripID, userID string) (*domain.Trip, error) {
	query := `
		UPDATE trips SET status = $1, finished_at = NOW()
		WHERE id = $2
		  AND (passenger_id = $3 OR driver_id = $3)
		  AND status IN ('SEARCHING', 'ACCEPTED', 'ARRIVED', 'IN_PROGRESS')
		RETURNING id, passenger_id, driver_id, status,
		          pickup_address, dest_address, pickup_lat, pickup_lng,
		          dest_lat, dest_lng, price_kzt, created_at, accepted_at, finished_at
	`
	row := r.db.QueryRow(ctx, query,
		domain.StatusCancelled, tripID, userID,
	)
	return scanTrip(row)
}

func (r *repository) SaveReview(ctx context.Context, tripID, reviewerID, targetID string, score int) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	_, err = tx.Exec(ctx,
		`INSERT INTO reviews (trip_id, reviewer_id, target_id, score) VALUES ($1, $2, $3, $4)`,
		tripID, reviewerID, targetID, score,
	)
	if err != nil {
		return err
	}

	_, err = tx.Exec(ctx,
		`UPDATE users SET rating = (
			SELECT ROUND(AVG(score)::NUMERIC, 2) FROM reviews WHERE target_id = $1
		) WHERE id = $1`,
		targetID,
	)
	if err != nil {
		return err
	}

	return tx.Commit(ctx)
}

func (r *repository) GetTripHistory(ctx context.Context, passengerID string) ([]domain.TripHistoryItem, error) {
	rows, err := r.db.Query(ctx, `
		SELECT t.id, t.pickup_address, t.dest_address, t.price_kzt,
		       COALESCE(TO_CHAR(t.finished_at AT TIME ZONE 'UTC', 'DD.MM.YYYY'), ''),
		       COALESCE(u.full_name, '')
		FROM trips t
		LEFT JOIN users u ON u.id = t.driver_id
		WHERE t.passenger_id = $1 AND t.status = 'COMPLETED'
		ORDER BY t.finished_at DESC NULLS LAST
		LIMIT 20
	`, passengerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []domain.TripHistoryItem
	for rows.Next() {
		var item domain.TripHistoryItem
		if err := rows.Scan(&item.ID, &item.PickupAddress, &item.DestAddress, &item.PriceKZT, &item.FinishedAt, &item.DriverName); err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	if items == nil {
		items = []domain.TripHistoryItem{}
	}
	return items, nil
}

func (r *repository) DeleteFCMTokens(ctx context.Context, tokens []string) error {
	_, err := r.db.Exec(ctx,
		`DELETE FROM sessions WHERE fcm_token = ANY($1)`,
		tokens,
	)
	return err
}

func scanTrip(row pgx.Row) (*domain.Trip, error) {
	trip := &domain.Trip{}
	err := row.Scan(
		&trip.ID, &trip.PassengerID, &trip.DriverID, &trip.Status,
		&trip.PickupAddress, &trip.DestAddress, &trip.PickupLat, &trip.PickupLng,
		&trip.DestLat, &trip.DestLng, &trip.PriceKZT,
		&trip.CreatedAt, &trip.AcceptedAt, &trip.FinishedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, domain.ErrInvalidTripStatus
		}
		return nil, fmt.Errorf("ошибка БД при обновлении статуса поездки: %w", err)
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
