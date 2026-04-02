package domain

import "errors"

var (
	ErrInternal            = errors.New("что-то пошло не так, попробуйте позже")
	ErrTripAlreadyAccepted = errors.New("поездка уже занята")
	ErrTripNotFound        = errors.New("поездка не была найдена")
)
