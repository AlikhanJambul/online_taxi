package domain

import (
	"context"
)

type Repository interface {
	CreateTrip(ctx context.Context, trip *Trip) error
	AcceptTrip(ctx context.Context, tripID string, driverID string) (*Trip, error)
	GetTrip(ctx context.Context, tripID string) (*Trip, error)
	GetFCMTokens(ctx context.Context, driverIDs []string) ([]string, error)
}
