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
			INSERT INTO driver_profiles(user_id, car_make, car_model, car_color, license_plate) 
			VALUES ($1, $2, $3, $4, $5) 
			RETURNING status;
`

	var status string

	err := r.db.QueryRow(ctx, query,
		driver.UserID, driver.CarMake, driver.CarModel, driver.CarColor, driver.LicensePlate,
	).Scan(&status)

	if err != nil {
		return "", err
	}

	return status, nil
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
