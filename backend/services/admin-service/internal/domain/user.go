package domain

type User struct {
	ID        string `json:"id,omitempty"`
	Email     string `json:"email,omitempty"`
	Phone     string `json:"phone,omitempty"`
	FullName  string `json:"full_name,omitempty"`
	Role      string `json:"role,omitempty"`
	AvatarURL string `json:"avatar_url,omitempty"`
}

const (
	DriverStatusApproved = "APPROVED"
	DriverStatusRejected = "REJECTED"
	DriverStatusPending  = "PENDING"
)
