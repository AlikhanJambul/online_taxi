package domain

import (
	"context"
	"github.com/google/uuid"
)

type Repository interface {
	SaveUser(ctx context.Context, data *User, token string, userID uuid.UUID, deviceID string) error
	GetUserByEmail(ctx context.Context, email string) (*User, error)
	SaveSession(ctx context.Context, userID string, token string, deviceID string) error
	ClearSession(ctx context.Context, refreshToken string) error
	SaveRefreshToken(ctx context.Context, token, deviceID string) error
	GetUserByDeviceID(ctx context.Context, deviceID string) (*User, error)
	UpdateFCMToken(ctx context.Context, userID, deviceID, fcmToken string) error
}
