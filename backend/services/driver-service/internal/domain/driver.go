package domain

type Driver struct {
	UserID       string `json:"user_id,omitempty"`
	CarMake      string `json:"car_make,omitempty"`
	CarModel     string `json:"car_model,omitempty"`
	CarColor     string `json:"car_color,omitempty"`
	LicensePlate string `json:"license_plate,omitempty"`
	Status       string `json:"status,omitempty"`
}
