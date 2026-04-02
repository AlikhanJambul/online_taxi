package usecase

type Role string

const (
	Passenger       Role = "PASSENGER"
	Driver          Role = "DRIVER"
	Admin           Role = "ADMIN"
	RoleUnspecified Role = "ROLE_UNSPECIFIED"
)

type RegisterRequestDTO struct {
	Phone    string
	Password string
	FullName string
	Email    string
	Role     string
	DeviceID string
}

type LoginRequestDTO struct {
	Email    string
	Password string
	DeviceID string
}

type RefreshRequestDTO struct {
	RefreshToken string
	DeviceID     string
}

type LogoutRequestDTO struct {
	RefreshToken string
}

type UpdateFCMRequestDTO struct {
	UserID   string
	DeviceID string
	FCMToken string
}

// RESPONSE

type AuthResponseDTO struct {
	AccessToken  string
	RefreshToken string
	UserID       string
	Role         string
}

type RefreshResponseDTO struct {
	AccessToken  string
	RefreshToken string
}
