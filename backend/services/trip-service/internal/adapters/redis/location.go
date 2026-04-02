package redis

import (
	"context"
	"fmt"
	"github.com/redis/go-redis/v9"
	"online_taxi/services/trip-service/internal/domain"
)

const driversGeoKey = "drivers:locations"

type LocationRepository struct {
	client *redis.Client
}

func NewLocationRepository(client *redis.Client) domain.DriverLocationRepository {
	return &LocationRepository{client: client}
}

func (r *LocationRepository) UpdateLocation(ctx context.Context, driverID string, lat, lng float64) error {
	err := r.client.GeoAdd(ctx, driversGeoKey, &redis.GeoLocation{
		Name:      driverID, // ID водителя будет именем точки
		Longitude: lng,      // ВНИМАНИЕ: Redis всегда просит сначала долготу (Lng), потом широту (Lat)!
		Latitude:  lat,
	}).Err()

	if err != nil {
		return fmt.Errorf("redis geoadd error: %w", err)
	}

	return nil
}
