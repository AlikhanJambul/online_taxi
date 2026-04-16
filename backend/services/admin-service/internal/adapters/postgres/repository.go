package postgres

import (
	"context"
	"github.com/jackc/pgx/v5/pgxpool"
	"online_taxi/services/admin-service/internal/domain"
)

type repository struct {
	db *pgxpool.Pool
}

func NewRepo(db *pgxpool.Pool) domain.Repository {
	return &repository{db: db}
}

func (r *repository) AcceptDriverProfile(ctx context.Context, id string, status string) error {
	query := `
			UPDATE driver_profiles
			SET status = $1
			WHERE user_id = $2;
`

	tag, err := r.db.Exec(ctx, query, status, id)

	if err != nil {
		return err
	}

	if tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}

	return nil
}

func (r *repository) GetUsers(ctx context.Context) ([]domain.User, error) {
	query := `
			SELECT
			    id,
				phone,
				email,
				full_name,
				role,
				avatar_url
			FROM
			    users;
`

	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}

	var users []domain.User

	for rows.Next() {
		var user domain.User

		if err := rows.Scan(
			&user.ID,
			&user.Phone,
			&user.Email,
			&user.FullName,
			&user.Role,
			&user.AvatarURL,
		); err != nil {
			return nil, err
		}

		users = append(users, user)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return users, nil
}

func (r *repository) GetDrivers(ctx context.Context) ([]domain.Driver, error) {
	query := `
				SELECT 
				    u.id, 
				    u.email, 
				    u.phone, 
				    u.full_name, 
				    u.role, 
				    u.avatar_url,
				    dp.car_make, 
				    dp.car_model, 
				    dp.car_color, 
				    dp.car_url, 
-- 				    dp.license_plate, 
				    dp.status
				FROM 
				    users u
				INNER JOIN 
				    driver_profiles dp ON u.id = dp.user_id;
`

	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}

	var users []domain.Driver

	for rows.Next() {
		var user domain.Driver

		if err := rows.Scan(
			&user.User.ID,
			&user.User.Email,
			&user.User.Phone,
			&user.User.FullName,
			&user.User.Role,
			&user.User.AvatarURL,
			&user.CarMake,
			&user.CarModel,
			&user.CarColor,
			//&user.LicensePlate,
			&user.CarUrl,
		); err != nil {
			return nil, err
		}

		users = append(users, user)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return users, nil
}
