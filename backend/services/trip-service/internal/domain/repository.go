package domain

import (
	"context"
)

type Repository interface {
	CreateTrip(ctx context.Context, trip *Trip) error
	AcceptTrip(ctx context.Context, tripID string, driverID string) (*Trip, error)
	GetTrip(ctx context.Context, tripID string) (*Trip, error)
	GetFCMTokens(ctx context.Context, driverIDs []string) ([]string, error)

	DriverArrived(ctx context.Context, tripID, driverID string) (*Trip, error)
	StartTrip(ctx context.Context, tripID, driverID string) (*Trip, error)
	CompleteTrip(ctx context.Context, tripID, driverID string) (*Trip, error)
	CancelTrip(ctx context.Context, tripID, userID string) (*Trip, error)

	DeleteFCMTokens(ctx context.Context, tokens []string) error
}
