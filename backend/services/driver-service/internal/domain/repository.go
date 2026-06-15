package domain

import (
	"context"
)

type DriverStats struct {
	Rating           float64
	TotalTrips       int32
	TotalEarningsKzt int64
}

type TripHistoryItem struct {
	ID            string `json:"id"`
	PickupAddress string `json:"pickup_address"`
	DestAddress   string `json:"dest_address"`
	PriceKZT      int64  `json:"price_kzt"`
	FinishedAt    string `json:"finished_at"`
}

type Repository interface {
	SaveDriver(ctx context.Context, driver *Driver) (string, error)
	GetDriver(ctx context.Context, id string) (*Driver, error)
	GetStats(ctx context.Context, driverID string) (*DriverStats, error)
	GetTripHistory(ctx context.Context, driverID string) ([]TripHistoryItem, error)
	StartShift(ctx context.Context, driverID string) error
}
