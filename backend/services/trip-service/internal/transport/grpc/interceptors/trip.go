package interceptors

import (
	"context"
	"online_taxi/services/shared/jwt"
	"strings"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

func TripInterceptor(tm *jwt.TokenManager) grpc.UnaryServerInterceptor {
	return func(
		ctx context.Context,
		req interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (interface{}, error) {

		md, ok := metadata.FromIncomingContext(ctx)
		if !ok {
			return nil, status.Error(codes.Unauthenticated, "метаданные не найдены")
		}

		values := md["authorization"]
		if len(values) == 0 {
			return nil, status.Error(codes.Unauthenticated, "токен авторизации не предоставлен")
		}

		accessToken := values[0]
		accessToken = strings.TrimPrefix(accessToken, "Bearer ")

		claims, err := tm.ParseToken(accessToken)
		if err != nil {
			return nil, status.Error(codes.Unauthenticated, "недействительный или просроченный токен")
		}

		ctx = context.WithValue(ctx, "userID", claims.UserID)
		ctx = context.WithValue(ctx, "role", claims.Role)

		return handler(ctx, req)
	}
}

func TimeoutInterceptor(timeout time.Duration) grpc.UnaryServerInterceptor {
	return func(
		ctx context.Context,
		req interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (interface{}, error) {

		ctx, cancel := context.WithTimeout(ctx, timeout)
		defer cancel() // Как только хендлер отработает, ресурсы освободятся

		return handler(ctx, req)
	}
}
