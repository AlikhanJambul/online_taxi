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

type NotificationConsumer struct {
	service usecase.Service
	logger  *loggerPkg.Logger
	ch      *amqp.Channel
}

func NewNotificationConsumer(service usecase.Service, logger *loggerPkg.Logger, ch *amqp.Channel) *NotificationConsumer {
	return &NotificationConsumer{
		service: service,
		logger:  logger,
		ch:      ch,
	}
}

func (c *NotificationConsumer) Start(ctx context.Context) error {
	msgs, err := c.ch.Consume(
		"notification.push",
		"",
		false,
		false,
		false,
		false,
		nil,
	)
	if err != nil {
		return fmt.Errorf("ошибка подписки на очередь notification.push: %w", err)
	}

	c.logger.Info("🔔 Воркер уведомлений запущен. Жду события...")

	for {
		select {
		case d, ok := <-msgs:
			if !ok {
				return fmt.Errorf("канал RabbitMQ закрыт")
			}

			var trip domain.Trip
			if err := json.Unmarshal(d.Body, &trip); err != nil || trip.ID == "" {
				c.logger.Warn("не удалось распарсить сообщение как Trip, пропускаем")
				d.Ack(false)
				continue
			}

			c.logger.Info("получено событие статуса %s для поездки %s", trip.Status, trip.ID)

			if err := c.service.NotifyTripStatusChange(context.Background(), &trip); err != nil {
				c.logger.Error("ошибка отправки уведомления для поездки %s: %v", trip.ID, err)
				d.Nack(false, true)
			} else {
				d.Ack(false)
			}

		case <-ctx.Done():
			return nil
		}
	}
}
