package domain

import "math"

const (
	BaseFare   = 500 // базовая стоимость посадки (тенге)
	PricePerKm = 150 // цена за км
)

type PriceEstimate struct {
	PriceKZT   int32
	DistanceKm float64
}

func CalculatePrice(pickupLat, pickupLng, destLat, destLng float64) PriceEstimate {
	distanceKm := haversine(pickupLat, pickupLng, destLat, destLng)
	return PriceEstimate{
		PriceKZT:   BaseFare + int32(distanceKm*PricePerKm),
		DistanceKm: distanceKm,
	}
}

func haversine(lat1, lng1, lat2, lng2 float64) float64 {
	const R = 6371.0
	dLat := (lat2 - lat1) * math.Pi / 180
	dLng := (lng2 - lng1) * math.Pi / 180
	a := math.Sin(dLat/2)*math.Sin(dLat/2) +
		math.Cos(lat1*math.Pi/180)*math.Cos(lat2*math.Pi/180)*
			math.Sin(dLng/2)*math.Sin(dLng/2)
	return R * 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))
}
