package mq

import (
	"fmt"
	"github.com/rabbitmq/amqp091-go"
	"log"
	"online_taxi/services/pkg/models"
	"time"
)

func ConnectToRMQ(cfg *models.RabbitMQ) (*amqp091.Connection, *amqp091.Channel, error) {
	dsn := fmt.Sprintf("amqp://%s:%s@%s:%s/", cfg.User, cfg.Password, cfg.Host, cfg.Port)

	var conn *amqp091.Connection
	var ch *amqp091.Channel
	var err error

	for i := 0; i < 10; i++ {
		conn, err = amqp091.Dial(dsn)
		if err == nil {
			ch, err = conn.Channel()
			if err == nil {
				return conn, ch, nil
			}
		}
		log.Printf("RabbitMQ not ready, retrying... (%d/10)", i+1)
		time.Sleep(3 * time.Second)
	}

	return nil, nil, fmt.Errorf("failed to connect to RabbitMQ: %w", err)
}
