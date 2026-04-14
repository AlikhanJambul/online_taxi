package app // или где у тебя лежит этот файл

import (
	"context"
	"log"
	"net/http"
	httpPkg "online_taxi/services/admin-service/internal/transport/http"
	"online_taxi/services/admin-service/internal/adapters/postgres"
	"online_taxi/services/admin-service/internal/app/usecase"
	"online_taxi/services/shared/config"
	"online_taxi/services/shared/database"
	"os"
	"os/signal"
	"syscall"
	"time"

	"online_taxi/services/shared/logger"
)

func Run() {
	cfg := config.Load()
	newLogger := logger.New("Admin-service")

	db, err := database.ConnectToDB(&cfg.DB)
	if err != nil {
		log.Fatalf("Ошибка подключения к БД: %v", err)
	}
	defer db.Close()

	repo := postgres.NewRepo(db)
	service := usecase.NewService(repo)
	handler := httpPkg.NewHandler(service, newLogger)

	mux := http.NewServeMux()

	mux.HandleFunc("GET /api/v1/admin/users", handler.GetUsers)
	mux.HandleFunc("POST /api/v1/admin/drivers/accept", handler.AcceptDriver)

	port := ":8080"
	srv := &http.Server{
		Addr:         port,
		Handler:      mux,
		ReadTimeout:  10 * time.Second, // Защита от медленных клиентов
		WriteTimeout: 10 * time.Second,
	}

	go func() {
		newLogger.Info("🚀 Admin-service запущен на порту %s", port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Критическая ошибка HTTP сервера: %v", err)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	<-quit
	newLogger.Info("Получен сигнал завершения. Останавливаем сервер...")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		newLogger.Error("Принудительное завершение сервера: %v", err)
	}

	newLogger.Info("Сервер успешно остановлен. До связи! 🏁")
}
