package postgres

import (
	"context"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"online_taxi/services/auth-service/internal/domain"
)

type Repository interface {
	SaveUser(ctx context.Context, data *domain.User, token string, userID uuid.UUID, deviceID string) error
	GetUserByEmail(ctx context.Context, email string) (*domain.User, error)
	SaveSession(ctx context.Context, userID string, token string, deviceID string) error
}

type repository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &repository{db: db}
}

func (r *repository) SaveUser(ctx context.Context, data *domain.User, token string, userID uuid.UUID, deviceID string) error {
	queryUser := `INSERT INTO users (id, phone, email, password_hash, full_name, role, avatar_url)  VALUES ($1, $2, $3, $4, $5, $6, $7);`
	querySession := `INSERT INTO sessions (user_id, refresh_token, device_id, expires_at) VALUES ($1, $2, $3, NOW() + INTERVAL '30 days');`

	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	_, err = tx.Exec(ctx, queryUser, userID, data.Phone, data.Email, data.Password, data.FullName, data.Role, "empty")
	if err != nil {
		return err
	}

	_, err = tx.Exec(ctx, querySession, userID, token, deviceID)
	if err != nil {
		return err
	}

	if err := tx.Commit(ctx); err != nil {
		return err
	}

	return nil
}

func (r *repository) SaveSession(ctx context.Context, userID string, token string, deviceID string) error {
	query := `INSERT INTO sessions (user_id, refresh_token, device_id, expires_at) VALUES ($1, $2, $3, NOW() + INTERVAL '30 days');`

	_, err := r.db.Exec(ctx, query, userID, token, deviceID)
	if err != nil {
		return err
	}

	return nil
}

func (r *repository) GetUserByEmail(ctx context.Context, email string) (*domain.User, error) {
	query := `SELECT id, phone, email, password_hash, full_name, role 
	          FROM users WHERE email = $1`

	var user domain.User

	err := r.db.QueryRow(ctx, query, email).Scan(
		&user.ID,
		&user.Phone,
		&user.Email,
		&user.Password,
		&user.FullName,
		&user.Role,
	)

	if err != nil {
		return nil, err
	}

	return &user, nil
}
