package domain

type EventPublisher interface {
	Publish(exchange, routingKey string, payload interface{}) error
}
