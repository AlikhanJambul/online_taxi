package config

import (
	"online_taxi/services/shared/models"
	"os"
)

func Load() *models.Config {
	db := models.Database{}
	rmq := models.RabbitMQ{}
	mail := models.Mailpit{}
	s3 := models.Minio{}

	db.User = os.Getenv("DB_USER")
	db.Password = os.Getenv("DB_PASSWORD")
	db.Host = os.Getenv("DB_HOST")
	db.Name = os.Getenv("DB_NAME")
	db.Port = os.Getenv("DB_PORT")
	db.RedisPort = os.Getenv("REDIS_PORT")
	db.RedisHost = os.Getenv("REDIS_HOST")

	rmq.User = os.Getenv("RMQ_USER")
	rmq.Password = os.Getenv("RMQ_PASSWORD")
	rmq.Host = os.Getenv("RMQ_HOST")
	rmq.Port = os.Getenv("RMQ_PORT")
	rmq.UIPort = os.Getenv("RMQ_UI_PORT")

	s3.User = os.Getenv("MINIO_USER")
	s3.Password = os.Getenv("MINIO_PASSWORD")
	s3.Port = os.Getenv("MINIO_PORT")
	s3.UIPort = os.Getenv("MINIO_UI_PORT")

	mail.Port = os.Getenv("SMTP_PORT")
	mail.Mail = os.Getenv("MAIL")
	mail.Password = os.Getenv("PASSWORD")
	//_ = os.Getenv("MAILPIT_UI_PORT")

	secretKey := os.Getenv("SECRET_KEY")

	return &models.Config{
		DB:        db,
		RMQ:       rmq,
		Mail:      mail,
		S3:        s3,
		SecretKey: secretKey,
	}
}
