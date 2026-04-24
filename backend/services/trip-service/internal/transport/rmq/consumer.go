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

func (h *ConsumerHandler) Start(ctx context.Context) error {
	msgs, err := h.ch.Consume(
		"matching.find_driver",
		"",
		false,
		false,
		false,
		false,
		nil,
	)
	if err != nil {
		return fmt.Errorf("ошибка подписки на очередь: %w", err)
	}

	h.logger.Info("🚀 Воркер подбора водителей (Matching) запущен. Жду новые заказы...")

	// Блокируем до завершения контекста
	for {
		select {
		case d, ok := <-msgs:
			if !ok {
				return fmt.Errorf("канал RabbitMQ закрыт")
			}
			var trip domain.Trip
			if err := json.Unmarshal(d.Body, &trip); err != nil {
				h.logger.Error("ошибка парсинга JSON: %v", err)
				d.Reject(false)
				continue
			}
			h.logger.Info("Поступил новый заказ %s!", trip.ID)
			err := h.service.FindAndNotifyDrivers(context.Background(), &trip)
			if err != nil {
				h.logger.Error("ошибка обработки заказа %s: %v", trip.ID, err)
				d.Nack(false, true)
			} else {
				d.Ack(false)
			}
		case <-ctx.Done():
			return nil
		}
	}
}
