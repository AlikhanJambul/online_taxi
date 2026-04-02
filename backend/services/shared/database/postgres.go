package database

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"online_taxi/services/shared/models"
)

func ConnectToDB(cfg *models.Database) (*pgxpool.Pool, error) {
	dsn := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable&pool_max_conns=10",
		cfg.User, cfg.Password, cfg.Host, cfg.Port, cfg.Name)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		return nil, fmt.Errorf("ошибка парсинга конфига БД: %w", err)
	}

	if err = pool.Ping(ctx); err != nil {
		return nil, fmt.Errorf("база данных недоступна (ping failed): %w", err)
	}

	fmt.Println("✅ Успешное подключение к PostgreSQL (pgxpool)!")

	return pool, nil
}
