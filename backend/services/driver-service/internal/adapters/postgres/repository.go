package postgres

import (
	"context"
	"errors"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"online_taxi/services/driver-service/internal/domain"
)

type repository struct {
	db *pgxpool.Pool
}

func NewRepo(db *pgxpool.Pool) domain.Repository {
	return &repository{db: db}
}

func (r *repository) SaveDriver(ctx context.Context, driver *domain.Driver) (string, error) {
	query := `
		INSERT INTO driver_profiles(user_id, car_make, car_model, car_color, license_plate, car_url) 
		VALUES ($1, $2, $3, $4, $5, $6) 
		ON CONFLICT (user_id) DO UPDATE
		SET
			car_make = EXCLUDED.car_make,
			car_model = EXCLUDED.car_model,
			car_color = EXCLUDED.car_color,
			license_plate = EXCLUDED.license_plate,
			status = CASE WHEN driver_profiles.status = 'REJECTED' THEN 'PENDING' ELSE driver_profiles.status END
		RETURNING status;
	`

	var status string

	err := r.db.QueryRow(ctx, query,
		driver.UserID, driver.CarMake, driver.CarModel, driver.CarColor, driver.LicensePlate, driver.CarPhotoURL,
	).Scan(&status)

	if err != nil {
		return "", err
	}

	return status, nil
}

func (r *repository) GetStats(ctx context.Context, driverID string) (*domain.DriverStats, error) {
	var stats domain.DriverStats

	err := r.db.QueryRow(ctx, `
		SELECT COALESCE(u.rating, 5.0),
		       COUNT(t.id),
		       COALESCE(SUM(t.price_kzt) FILTER (
		           WHERE t.finished_at >= COALESCE(u.shift_started_at, '-infinity')
		       ), 0)
		FROM users u
		LEFT JOIN trips t ON t.driver_id = u.id AND t.status = 'COMPLETED'
		WHERE u.id = $1::uuid
		GROUP BY u.rating, u.shift_started_at
	`, driverID).Scan(&stats.Rating, &stats.TotalTrips, &stats.TotalEarningsKzt)

	if err != nil {
		// Если поездок нет совсем — pgx вернёт ErrNoRows из-за GROUP BY
		stats.Rating = 5.0
		return &stats, nil
	}

	return &stats, nil
}

func (r *repository) GetTripHistory(ctx context.Context, driverID string) ([]domain.TripHistoryItem, error) {
	rows, err := r.db.Query(ctx, `
		SELECT id, pickup_address, dest_address, price_kzt,
		       COALESCE(TO_CHAR(finished_at AT TIME ZONE 'UTC', 'DD.MM.YYYY'), '')
		FROM trips
		WHERE driver_id = $1 AND status = 'COMPLETED'
		ORDER BY finished_at DESC NULLS LAST
		LIMIT 20
	`, driverID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []domain.TripHistoryItem
	for rows.Next() {
		var item domain.TripHistoryItem
		if err := rows.Scan(&item.ID, &item.PickupAddress, &item.DestAddress, &item.PriceKZT, &item.FinishedAt); err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	if items == nil {
		items = []domain.TripHistoryItem{}
	}
	return items, nil
}

func (r *repository) StartShift(ctx context.Context, driverID string) error {
	_, err := r.db.Exec(ctx, `UPDATE users SET shift_started_at = NOW() WHERE id = $1::uuid`, driverID)
	return err
}

func (r *repository) GetDriver(ctx context.Context, id string) (*domain.Driver, error) {
	query := `
		SELECT user_id, car_make, car_model, car_color, license_plate, status
		FROM driver_profiles
		WHERE user_id = $1;
	`

	var resp domain.Driver

	err := r.db.QueryRow(ctx, query, id).Scan(
		&resp.UserID,
		&resp.CarMake,
		&resp.CarModel,
		&resp.CarColor,
		&resp.LicensePlate,
		&resp.Status,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, domain.ErrDriverNotFound
		}

		return nil, err
	}

	return &resp, nil
}
