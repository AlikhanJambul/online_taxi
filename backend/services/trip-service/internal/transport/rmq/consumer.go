package rmq

import (
	amqp "github.com/rabbitmq/amqp091-go"
	loggerPkg "online_taxi/services/shared/logger"
	"online_taxi/services/trip-service/internal/app/usecase"
)

type ConsumerHandler struct {
	service usecase.Service
	logger  *loggerPkg.Logger
}

func NewConsumerHandler(s usecase.Service) *ConsumerHandler {
	return &ConsumerHandler{service: s}
}

// Этот метод запускается в main.go как горутина
func (h *ConsumerHandler) StartListening(msgs <-chan amqp.Delivery) {
	for d := range msgs {
		//var tripEvent TripEvent
		//json.Unmarshal(d.Body, &tripEvent)

		// Consumer парсит сообщение и дергает Usecase!
		// h.service.FindDriversForTrip(...)

		d.Ack(false)
	}
}
