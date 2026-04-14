package domain

import "context"

type Repository interface {
	GetUsers(ctx context.Context) ([]User, error)
	AcceptDriverProfile(ctx context.Context, id string, status string) error
}
