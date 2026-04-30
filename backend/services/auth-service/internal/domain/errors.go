package domain

import "errors"

var (
	ErrInvalidEmailOrPassword = errors.New("неверный email или пароль")
	ErrInternal               = errors.New("что-то пошло не так, попробуйте позже")
	ErrNilToken               = errors.New("в базе нет токена")
	ErrUserNotFound           = errors.New("пользователь не найден")
	ErrInvalidData            = errors.New("неверные данные user_id, fcm_token, device_id")
	ErrUnauth                 = errors.New("пользователь не авторизован")
)
