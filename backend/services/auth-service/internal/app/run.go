package app

import (
	"log"
	"net"
	"online_taxi/services/auth-service/internal/jwt"
	"online_taxi/services/pkg/logger"

	"google.golang.org/grpc"

	pb "online_taxi/gen/auth-service"

	"online_taxi/services/auth-service/internal/adapters/postgres"
	"online_taxi/services/auth-service/internal/app/usecase"
	grpcHandler "online_taxi/services/auth-service/internal/transport/grpc"
	"online_taxi/services/pkg/config"
	"online_taxi/services/pkg/database"
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

	grpcServer := grpc.NewServer()

	pb.RegisterAuthServiceServer(grpcServer, h)

	log.Println("Auth-сервис успешно запущен на порту :50051")
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("Ошибка при запуске gRPC сервера: %v", err)
	}
}
