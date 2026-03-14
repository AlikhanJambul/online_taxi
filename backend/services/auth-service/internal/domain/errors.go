package domain

import "errors"

var (
	ErrInvalidEmailOrPassword = errors.New("неверный email или пароль")
	ErrInternalError          = errors.New("что-то пошло не так, попробуйте позже")
)

func CheckError(err error) int {
	if errors.Is(err, ErrInvalidEmailOrPassword) {
		return 401
	}

	return 500
}
