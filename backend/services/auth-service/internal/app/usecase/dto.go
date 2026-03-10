package usecase

type Role string

const (
	Passenger       Role = "PASSENGER"
	Driver          Role = "DRIVER"
	Admin           Role = "ADMIN"
	RoleUnspecified Role = "ROLE_UNSPECIFIED"
)

type RegisterRequest struct {
	Phone    string
	Password string
	FullName string
	Email    string
	Role     string
	DeviceID string
}

type LoginRequest struct {
	Phone    string
	Password string
	DeviceID string
}

type RefreshRequest struct {
	RefreshToken string
	DeviceID     string
}

type LogoutRequest struct {
	RefreshToken string
}

// RESPONSE

type AuthResponse struct {
	AccessToken  string
	RefreshToken string
	UserID       string
	Role         string
}

type RefreshResponse struct {
	AccessToken  string
	RefreshToken string
}
