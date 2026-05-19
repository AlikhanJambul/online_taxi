package main

import (
	"context"
	"log"
	"online_taxi/services/shared/config"
	"online_taxi/services/shared/database"
	"online_taxi/services/shared/logger"
	"online_taxi/services/shared/mq"
	"online_taxi/services/trip-service/internal/adapters/firebase"
	"online_taxi/services/trip-service/internal/adapters/postgres"
	location "online_taxi/services/trip-service/internal/adapters/redis"
	"online_taxi/services/trip-service/internal/adapters/rmq"
	"online_taxi/services/trip-service/internal/app/usecase"
	consumer "online_taxi/services/trip-service/internal/transport/rmq"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	cfg := config.Load()

	newLogger := logger.New("Notification-service")

	connPostgres, err := database.ConnectToDB(&cfg.DB)
	if err != nil {
		log.Fatalf("Ошибка подключения к БД postgres: %v", err)
	}
	defer connPostgres.Close()

	connRedis, err := database.ConnectToRedis(cfg.DB)
	if err != nil {
		log.Fatalf("Ошибка подключения к Redis: %v", err)
	}

	connRMQ, ch, err := mq.ConnectToRMQ(&cfg.RMQ)
	if err != nil {
		log.Fatalf("Ошибка подключения к RabbitMQ: %v", err)
	}

	locationRepo := location.NewLocationRepository(connRedis)

	publisher, err := rmq.NewRabbitPublisher(connRMQ, ch)
	if err != nil {
		log.Fatalf("Ошибка создания publisher: %v", err)
	}

	notification, err := firebase.New(cfg.Firebase.CredentialsPath)
	if err != nil {
		log.Fatalf("Ошибка подключения к Firebase: %v", err)
	}

	repo := postgres.NewRepo(connPostgres)
	service := usecase.NewService(repo, publisher, locationRepo, notification, newLogger)

	handler := consumer.NewNotificationConsumer(service, newLogger, ch)

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	go func() {
		quit := make(chan os.Signal, 1)
		signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
		<-quit
		cancel()
	}()

	if err := handler.Start(ctx); err != nil {
		newLogger.Error("воркер уведомлений завершился с ошибкой: %v", err)
	}
}
