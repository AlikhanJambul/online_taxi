package app

import (
	"fmt"
	"log"
	"net"
	"online_taxi/services/shared/jwt"
	"online_taxi/services/shared/logger"
	"online_taxi/services/shared/mq"
	location "online_taxi/services/trip-service/internal/adapters/redis"
	"online_taxi/services/trip-service/internal/adapters/rmq"
	"online_taxi/services/trip-service/internal/transport/grpc/interceptors"
	"time"

	"google.golang.org/grpc"

	pb "online_taxi/gen/trip-service"

	"online_taxi/services/shared/config"
	"online_taxi/services/shared/database"
	"online_taxi/services/trip-service/internal/adapters/postgres"
	"online_taxi/services/trip-service/internal/app/usecase"
	grpcHandler "online_taxi/services/trip-service/internal/transport/grpc"
)

func Run() {
	cfg := config.Load()
	newLogger := logger.New("Trip-service")

	tm := jwt.NewTokenManager(cfg.SecretKey)

	connPostgres, err := database.ConnectToDB(&cfg.DB)
	if err != nil {
		log.Fatalf("Ошибка подключения к БД postgres: %v", err)
	}
	defer connPostgres.Close()

	connRedis, err := database.ConnectToRedis(cfg.DB)
	if err != nil {
		log.Fatalf("Ошибка подключения к БД redis: %v", err)
	}

	connRMQ, ch, err := mq.ConnectToRMQ(&cfg.RMQ)
	if err != nil {
		log.Fatalf("Ошибка подключения к брокеру очереди rmq: %v", err)
	}

	locationRepo := location.NewLocationRepository(connRedis)

	publisher, err := rmq.NewRabbitPublisher(connRMQ, ch)
	if err != nil {
		log.Fatalf("Ошибка подключения к очереди: %v", err)
	}

	repo := postgres.NewRepo(connPostgres)
	service := usecase.NewService(repo, publisher, locationRepo, newLogger)
	h := grpcHandler.NewHandler(service, newLogger)

	port := fmt.Sprintf(":%s", cfg.Services.TripPort)

	lis, err := net.Listen("tcp", port)
	if err != nil {
		log.Fatalf("Не удалось прослушать порт: %v", err)
	}

	grpcServer := grpc.NewServer(
		grpc.ChainUnaryInterceptor(
			interceptors.TripInterceptor(tm),
			interceptors.TimeoutInterceptor(10*time.Second),
		),
	)

	pb.RegisterTripServiceServer(grpcServer, h)

	log.Println("Trip-сервис успешно запущен на порту " + port)
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("Ошибка при запуске gRPC сервера: %v", err)
	}
}
