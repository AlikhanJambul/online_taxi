package usecase

import (
	"context"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"online_taxi/services/auth-service/internal/adapters/postgres"
	"online_taxi/services/auth-service/internal/domain"
	"online_taxi/services/auth-service/jwt"
)

type Service interface {
	CreateUser(ctx context.Context, dto *RegisterRequest) (*AuthResponse, error)
}

type service struct {
	repo postgres.Repository
	tm   *jwt.TokenManager
}

func NewService(repo postgres.Repository, tm *jwt.TokenManager) Service {
	return &service{repo: repo, tm: tm}
}

func (s *service) CreateUser(ctx context.Context, dto *RegisterRequest) (*AuthResponse, error) {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(dto.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	uID := uuid.New()

	tokens, err := s.tm.GenerateTokenPair(uID.String(), string(dto.Role))
	if err != nil {
		return nil, err
	}

	user := domain.User{
		Phone:    dto.Phone,
		Email:    dto.Email,
		FullName: dto.FullName,
		Password: string(hashedPassword),
		Role:     dto.Role,
	}

	if err := s.repo.SaveUser(ctx, &user, tokens.RefreshToken, uID, dto.DeviceID); err != nil {
		return nil, err
	}

	response := AuthResponse{
		AccessToken:  tokens.AccessToken,
		RefreshToken: tokens.RefreshToken,
		UserID:       uID.String(),
		Role:         dto.Role,
	}

	return &response, nil
}
