package domain

import "fmt"

// Заголовки
const (
	titleNewTrip    = "Новый заказ!"
	titleAccepted   = "Водитель найден"
	titleArrived    = "Водитель прибыл"
	titleInProgress = "Поездка началась"
	titleCompleted  = "Поездка завершена"
	titleCancelled  = "Поездка отменена"
)

type PushNotification struct {
	Title string
	Body  string
}

// Для водителя — новый заказ
func NotifyNewTrip(tripID string) PushNotification {
	return PushNotification{
		Title: titleNewTrip,
		Body:  fmt.Sprintf("Новый заказ #%s рядом с вами", tripID),
	}
}

// Для пассажира — водитель принял
func NotifyDriverAccepted(driverName string) PushNotification {
	return PushNotification{
		Title: titleAccepted,
		Body:  fmt.Sprintf("Водитель %s едет к вам", driverName),
	}
}

// Для пассажира — водитель на месте
func NotifyDriverArrived() PushNotification {
	return PushNotification{
		Title: titleArrived,
		Body:  "Водитель ждёт вас",
	}
}

// Для пассажира — поездка началась
func NotifyTripStarted() PushNotification {
	return PushNotification{
		Title: titleInProgress,
		Body:  "Хорошей поездки!",
	}
}

// Для обоих — поездка завершена
func NotifyTripCompleted() PushNotification {
	return PushNotification{
		Title: titleCompleted,
		Body:  "Не забудьте оставить отзыв",
	}
}

// Для обоих — поездка отменена
func NotifyTripCancelled() PushNotification {
	return PushNotification{
		Title: titleCancelled,
		Body:  "Поездка была отменена",
	}
}
