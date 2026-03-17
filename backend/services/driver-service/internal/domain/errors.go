package domain

import "errors"

var (
	ErrEmptyCtx       = errors.New("userID не найден в контексте или имеет неверный тип")
	ErrInternal       = errors.New("что-то пошло не так, попробуйте позже")
	ErrDriverNotFound = errors.New("профиль водителя не найден")
)
