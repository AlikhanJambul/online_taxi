package domain

import (
	"context"
)

type TripHistoryItem struct {
	ID            string `json:"id"`
	PickupAddress string `json:"pickup_address"`
	DestAddress   string `json:"dest_address"`
	PriceKZT      int64  `json:"price_kzt"`
	FinishedAt    string `json:"finished_at"`
	DriverName    string `json:"driver_name"`
}

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
	SaveReview(ctx context.Context, tripID, reviewerID, targetID string, score int) error
	GetTripHistory(ctx context.Context, passengerID string) ([]TripHistoryItem, error)
}
