package app

import (
	"log"
	"net"
	"online_taxi/services/auth-service/internal/transport/grpc/interceptors"
	"online_taxi/services/shared/jwt"
	"online_taxi/services/shared/logger"
	"time"

	"google.golang.org/grpc"

	pb "online_taxi/gen/auth-service"

	"online_taxi/services/auth-service/internal/adapters/postgres"
	"online_taxi/services/auth-service/internal/app/usecase"
	grpcHandler "online_taxi/services/auth-service/internal/transport/grpc"
	"online_taxi/services/shared/config"
	"online_taxi/services/shared/database"
)

func Run() {
	cfg := config.Load()
	newLogger := logger.New("Auth-service")

	db, err := database.ConnectToDB(&cfg.DB)
	if err != nil {
		log.Fatalf("Ошибка подключения к БД: %v", err)
	}
	defer db.Close()

	tm := jwt.NewTokenManager(cfg.SecretKey)
	repo := postgres.NewRepository(db)
	service := usecase.NewService(repo, tm)

	h := grpcHandler.NewHandler(service, newLogger)

	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("Не удалось прослушать порт: %v", err)
	}

	grpcServer := grpc.NewServer(
		grpc.ChainUnaryInterceptor(
			interceptors.AuthInterceptor(tm),
			interceptors.TimeoutInterceptor(3*time.Second),
		),
	)

	pb.RegisterAuthServiceServer(grpcServer, h)

	log.Println("Auth-сервис успешно запущен на порту :50051")
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("Ошибка при запуске gRPC сервера: %v", err)
	}
}
