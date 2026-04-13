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
		"matching.find_driver", // Имя очереди (из твоего конфига)
		"",                     // consumer tag
		false,                  // autoAck = false (мы сами будем подтверждать)
		false,                  // exclusive
		false,                  // noLocal
		false,                  // noWait
		nil,                    // args
	)
	if err != nil {
		return fmt.Errorf("ошибка подписки на очередь: %w", err)
	}

	h.logger.Info("🚀 Воркер подбора водителей (Matching) запущен. Жду новые заказы...")

	// Запускаем чтение в отдельной горутине, чтобы не блокировать основной поток
	go func() {
		for d := range msgs {
			var trip domain.Trip

			// 1. Распаковываем JSON
			if err := json.Unmarshal(d.Body, &trip); err != nil {
				h.logger.Error("ошибка парсинга JSON из RMQ: %v", err)
				d.Reject(false) // Выбрасываем кривое сообщение
				continue
			}

			h.logger.Info("Поступил новый заказ %s! Ищу водителей...", trip.ID)

			// 2. Передаем заказ в мозг (Usecase) для поиска водителей
			err := h.service.FindAndNotifyDrivers(context.Background(), &trip)
			if err != nil {
				h.logger.Error("ошибка обработки заказа %s: %v", trip.ID, err)
				// Nack позволяет вернуть сообщение в очередь (если, например, отвалилась БД)
				d.Nack(false, true)
			} else {
				// 3. Успешно! Говорим Рэббиту удалить сообщение
				d.Ack(false)
			}
		}
	}()

	return nil
}
