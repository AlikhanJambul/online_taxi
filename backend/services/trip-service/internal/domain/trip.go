package domain

import "time"

type TripStatus string

const (
	StatusSearching  TripStatus = "SEARCHING"
	StatusAccepted   TripStatus = "ACCEPTED"
	StatusArrived    TripStatus = "ARRIVED"
	StatusInProgress TripStatus = "IN_PROGRESS"
	StatusCompleted  TripStatus = "COMPLETED"
	StatusCancelled  TripStatus = "CANCELLED"
)

type Trip struct {
	ID          string
	PassengerID string
	DriverID    *string

	Status TripStatus

	PickupAddress string
	DestAddress   string
	PickupLat     float64
	PickupLng     float64
	DestLat       float64
	DestLng       float64

	PriceKZT int64

	CreatedAt  time.Time
	AcceptedAt *time.Time
	FinishedAt *time.Time
}
