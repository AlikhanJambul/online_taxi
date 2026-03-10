package domain

import (
	"github.com/google/uuid"
	"time"
)

type User struct {
	ID        uuid.UUID `json:"id,omitempty"`
	Phone     string    `json:"phone"`
	Email     string    `json:"email"`
	Password  string    `json:"password_hash"`
	FullName  string    `json:"full_name"`
	Role      string    `json:"role"`
	AvatarURL string    `json:"avatarURL,omitempty"`
	Rating    float32   `json:"rating"`
	IsBlocked bool      `json:"is_blocked"`
	CreatedAt time.Time `json:"created_at"`
}
