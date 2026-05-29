package usecase

type AcceptDriverDTO struct {
	ID     string `json:"id"`
	Accept bool   `json:"accept"`
}

type LoginDTO struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}
