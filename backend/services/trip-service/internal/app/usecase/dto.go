package usecase

// DTO для создания поездки (от пассажира)
type CreateTripDTO struct {
	PassengerID   string // Хендлер достанет это из JWT токена!
	PickupAddress string
	DestAddress   string
	PickupLat     float64
	PickupLng     float64
	DestLat       float64
	DestLng       float64
	PriceKZT      int64
}

// DTO для принятия поездки (от водителя)
type AcceptTripDTO struct {
	TripID   string
	DriverID string // Хендлер достанет это из JWT токена водителя!
}

// DTO для отправки координат (от водителя в Redis/Стрим)
type LocationDTO struct {
	DriverID string // Кто отправляет координаты (из токена)
	TripID   string // Может быть пустой строкой "", если просто ищет заказ
	Lat      float64
	Lng      float64
}

type EstimatePriceReqDTO struct {
	PickupLat float64
	PickupLng float64
	DestLat   float64
	DestLng   float64
}
