package domain

import "errors"

var (
	ErrNotFound = errors.New("профиль не найден")
	ErrInternal = errors.New("что-то пошло не так, попробуйте позже")
)
