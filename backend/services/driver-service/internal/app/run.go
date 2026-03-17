package app

import (
	"google.golang.org/grpc"
	"log"
	"net"
	pb "online_taxi/gen/driver-service"
	"online_taxi/services/driver-service/internal/adapters/postgres"
	"online_taxi/services/driver-service/internal/app/usecase"
	grpcHandler "online_taxi/services/driver-service/internal/transport/grpc"
	"online_taxi/services/driver-service/internal/transport/grpc/interceptors"
	"online_taxi/services/pkg/config"
	"online_taxi/services/pkg/database"
	"online_taxi/services/pkg/jwt"
	"online_taxi/services/pkg/logger"
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

	tm := jwt.NewTokenManager(cfg.SecretKey)
	repo := postgres.NewRepo(db)
	service := usecase.NewService(repo)

	h := grpcHandler.NewHandler(service, newLogger)

	lis, err := net.Listen("tcp", ":50052")
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

	log.Println("Auth-сервис успешно запущен на порту :50052")
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("Ошибка при запуске gRPC сервера: %v", err)
	}
}
