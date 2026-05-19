package domain

import "errors"

var (
	ErrInternal            = errors.New("что-то пошло не так, попробуйте позже")
	ErrTripAlreadyAccepted = errors.New("поездка уже занята")
	ErrTripNotFound        = errors.New("поездка не была найдена")
	ErrInvalidTripStatus   = errors.New("недопустимый переход статуса поездки")
	ErrNotTripParticipant  = errors.New("вы не являетесь участником этой поездки")
)
