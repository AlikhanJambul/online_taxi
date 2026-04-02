package domain

import "context"

// DriverLocationRepository отвечает за хранение текущих координат свободных водителей
type DriverLocationRepository interface {
	// UpdateLocation обновляет гео-позицию водителя в Redis
	UpdateLocation(ctx context.Context, driverID string, lat, lng float64) error

	// TODO: В будущем для сервиса matching тут будет метод:
	// TODO: FindNearest(ctx context.Context, lat, lng float64, radiusKm float64) ([]string, error)
}
