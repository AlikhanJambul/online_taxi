package domain

type User struct {
	ID        string `json:"id,omitempty"`
	Email     string `json:"email,omitempty"`
	Phone     string `json:"phone,omitempty"`
	FullName  string `json:"full_name,omitempty"`
	Role      string `json:"role,omitempty"`
	AvatarURL string `json:"avatar_url,omitempty"`
}

type Driver struct {
	User         User
	CarMake      string `json:"car_make"`
	CarModel     string `json:"car_model"`
	CarColor     string `json:"car_color"`
	CarUrl       string `json:"car_url"`
	LicensePlate string `json:"license_plate"`
	Status       string `json:"status"`
}

const (
	DriverStatusApproved = "APPROVED"
	DriverStatusRejected = "REJECTED"
	DriverStatusPending  = "PENDING"
)
