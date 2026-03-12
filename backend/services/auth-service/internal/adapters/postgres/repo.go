package postgres

import (
	"context"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"online_taxi/services/auth-service/internal/domain"
)

type Repository interface {
	SaveUser(ctx context.Context, data *domain.User, token string, userID uuid.UUID, deviceID string) error
}

type repository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &repository{db: db}
}

func (r *repository) SaveUser(ctx context.Context, data *domain.User, token string, userID uuid.UUID, deviceID string) error {
	requestUser := `INSERT INTO users (id, phone, email, password_hash, full_name, role, avatar_url)  VALUES ($1, $2, $3, $4, $5, $6, $7);`
	requestSession := `INSERT INTO sessions (user_id, refresh_token, device_id, expires_at) VALUES ($1, $2, $3, NOW() + INTERVAL '30 days');`

	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	_, err = tx.Exec(ctx, requestUser, userID, data.Phone, data.Email, data.Password, data.FullName, data.Role, "empty")
	if err != nil {
		return err
	}

	_, err = tx.Exec(ctx, requestSession, userID, token, deviceID)
	if err != nil {
		return err
	}

	if err := tx.Commit(ctx); err != nil {
		return err
	}

	return nil
}
