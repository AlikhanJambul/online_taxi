package domain

import "context"

// DriverLocationRepository отвечает за хранение текущих координат свободных водителей
type DriverLocationRepository interface {
	// UpdateLocation updates driver's position
	UpdateLocation(ctx context.Context, driverID string, lat, lng float64) error
	// FindNearest finds 5 nearest drivers according to lat and lng
	FindNearest(ctx context.Context, lat, lng float64, radiusKm float64) ([]string, error)
}
