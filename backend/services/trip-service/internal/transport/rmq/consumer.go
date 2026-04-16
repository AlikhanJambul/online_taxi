package rmq

import (
	"context"
	"encoding/json"
	"fmt"
	amqp "github.com/rabbitmq/amqp091-go"
	loggerPkg "online_taxi/services/shared/logger"
	"online_taxi/services/trip-service/internal/app/usecase"
	"online_taxi/services/trip-service/internal/domain"
)

type ConsumerHandler struct {
	service usecase.Service // Наш мозг из бизнес-логики
	logger  *loggerPkg.Logger
	ch      *amqp.Channel
}

func NewConsumerHandler(service usecase.Service, logger *loggerPkg.Logger, ch *amqp.Channel) *ConsumerHandler {
	return &ConsumerHandler{
		service: service,
		logger:  logger,
		ch:      ch,
	}
}

// Start запускает бесконечный цикл прослушивания очереди
func (h *ConsumerHandler) Start() error {
	msgs, err := h.ch.Consume(
		"matching.find_driver",
		"",    // consumer tag
		false, // autoAck = false (мы сами будем подтверждать)
		false, // exclusive
		false, // noLocal
		false, // noWait
		nil,   // args
	)
	if err != nil {
		return fmt.Errorf("ошибка подписки на очередь: %w", err)
	}

	h.logger.Info("🚀 Воркер подбора водителей (Matching) запущен. Жду новые заказы...")

	go func() {
		for d := range msgs {
			var trip domain.Trip

			if err := json.Unmarshal(d.Body, &trip); err != nil {
				h.logger.Error("ошибка парсинга JSON из RMQ: %v", err)
				d.Reject(false) // Выбрасываем кривое сообщение
				continue
			}

			h.logger.Info("Поступил новый заказ %s! Ищу водителей...", trip.ID)

			err := h.service.FindAndNotifyDrivers(context.Background(), &trip)
			if err != nil {
				h.logger.Error("ошибка обработки заказа %s: %v", trip.ID, err)
				d.Nack(false, true)
			} else {
				// 3. Успешно! Говорим Рэббиту удалить сообщение
				d.Ack(false)
			}
		}
	}()

	return nil
}
