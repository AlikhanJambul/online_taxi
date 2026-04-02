package rmq

import (
	"encoding/json"
	"fmt"
	amqp "github.com/rabbitmq/amqp091-go"
)

type RabbitPublisher struct {
	conn *amqp.Connection
	ch   *amqp.Channel
}

func NewRabbitPublisher(conn *amqp.Connection, ch *amqp.Channel) (*RabbitPublisher, error) {
	return &RabbitPublisher{
		conn: conn,
		ch:   ch,
	}, nil
}

func (p *RabbitPublisher) Publish(exchange, routingKey string, payload interface{}) error {
	body, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("failed to marshal payload: %w", err)
	}

	err = p.ch.Publish(
		exchange,   // Имя обменника (например, "trip.events")
		routingKey, // Ключ (например, "trip.created")
		false,      // mandatory
		false,      // immediate
		amqp.Publishing{
			ContentType:  "application/json",
			Body:         body,
			DeliveryMode: amqp.Persistent, // Сообщение сохранится на диск RMQ (не потеряется при рестарте)
		},
	)

	if err != nil {
		return fmt.Errorf("failed to publish message: %w", err)
	}

	return nil
}

func (p *RabbitPublisher) Close() {
	p.ch.Close()
	p.conn.Close()
}
