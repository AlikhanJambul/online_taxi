package models

type Config struct {
	DB        Database
	RMQ       RabbitMQ
	S3        Minio
	Mail      Mailpit
	SecretKey string
}
