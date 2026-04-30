package app

import (
	"fmt"
	"google.golang.org/grpc"
	"log"
	"net"
	pb "online_taxi/gen/driver-service"
	"online_taxi/services/driver-service/internal/adapters/postgres"
	"online_taxi/services/driver-service/internal/app/usecase"
	grpcHandler "online_taxi/services/driver-service/internal/transport/grpc"
	"online_taxi/services/driver-service/internal/transport/grpc/interceptors"
	"online_taxi/services/shared/config"
	"online_taxi/services/shared/database"
	"online_taxi/services/shared/jwt"
	"online_taxi/services/shared/logger"
	"online_taxi/services/shared/minio"
	"time"
)

func Run() {
	cfg := config.Load()
	newLogger := logger.New("Driver-service")

	db, err := database.ConnectToDB(&cfg.DB)
	if err != nil {
		log.Fatalf("Ошибка подключения к БД: %v", err)
	}
	defer db.Close()

	// TODO: возможно заменить на ip компа
	endpoint := fmt.Sprintf("minio:%s", cfg.S3.Port)

	tm := jwt.NewTokenManager(cfg.SecretKey)
	s3Storage, err := minio.NewFileStorage(endpoint, cfg.S3.User, cfg.S3.Password, "cars")
	repo := postgres.NewRepo(db)
	service := usecase.NewService(repo, s3Storage, cfg.S3.Port)

	h := grpcHandler.NewHandler(service, newLogger)

	port := fmt.Sprintf(":%s", cfg.Services.DriverPort)

	lis, err := net.Listen("tcp", port)
	if err != nil {
		log.Fatalf("Не удалось прослушать порт: %v", err)
	}

	grpcServer := grpc.NewServer(
		grpc.ChainUnaryInterceptor(
			interceptors.DriverInterceptor(tm),
			interceptors.TimeoutInterceptor(3*time.Second),
		),
	)

	pb.RegisterDriverServiceServer(grpcServer, h)

	log.Println("Auth-сервис успешно запущен на порту " + port)
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("Ошибка при запуске gRPC сервера: %v", err)
	}
}
