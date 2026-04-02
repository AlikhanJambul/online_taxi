package database

import (
	"context"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
	"online_taxi/services/shared/models"
)

func ConnectToRedis(cfg *models.Database) (*redis.Client, error) {
	addr := fmt.Sprintf("%s:%s", cfg.Host, cfg.Port)

	client := redis.NewClient(&redis.Options{
		Addr:     addr,
		Password: "", // Пароль из .env
		DB:       0,  // Номер базы (0 по умолчанию)
	})

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := client.Ping(ctx).Err(); err != nil {
		return nil, fmt.Errorf("ошибка подключения к Redis: %w", err)
	}

	fmt.Println("Успешное подключение к Redis!")

	return client, nil
}
