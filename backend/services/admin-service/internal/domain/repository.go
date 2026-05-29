package domain

import "context"

type Repository interface {
	GetUsers(ctx context.Context) ([]User, error)
	AcceptDriverProfile(ctx context.Context, id string, status string) error
	GetDrivers(ctx context.Context) ([]Driver, error)
	GetUserByEmail(ctx context.Context, email string) (*UserAuth, error)
}
