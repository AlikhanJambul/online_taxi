package usecase

import (
	"context"
	"golang.org/x/crypto/bcrypt"
	"online_taxi/services/admin-service/internal/domain"
	"online_taxi/services/shared/jwt"
	"time"
)

type Service interface {
	GetUsers(ctx context.Context) ([]domain.User, error)
	AcceptDriver(ctx context.Context, dto AcceptDriverDTO) error
	GetDrivers(ctx context.Context) ([]domain.Driver, error)
	Login(ctx context.Context, dto LoginDTO) (string, error)
}

type service struct {
	repo domain.Repository
	tm   *jwt.TokenManager
}

func NewService(repo domain.Repository, tm *jwt.TokenManager) Service {
	return &service{repo: repo, tm: tm}
}

func (s *service) GetUsers(ctx context.Context) ([]domain.User, error) {
	return s.repo.GetUsers(ctx)
}

func (s *service) AcceptDriver(ctx context.Context, dto AcceptDriverDTO) error {
	status := domain.DriverStatusRejected

	if dto.Accept {
		status = domain.DriverStatusApproved
	}

	return s.repo.AcceptDriverProfile(ctx, dto.ID, status)
}

func (s *service) GetDrivers(ctx context.Context) ([]domain.Driver, error) {
	return s.repo.GetDrivers(ctx)
}

func (s *service) Login(ctx context.Context, dto LoginDTO) (string, error) {
	user, err := s.repo.GetUserByEmail(ctx, dto.Email)
	if err != nil {
		return "", domain.ErrInvalidCredentials
	}

	if user.Role != "ADMIN" {
		return "", domain.ErrForbidden
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(dto.Password)); err != nil {
		return "", domain.ErrInvalidCredentials
	}

	token, err := s.tm.GenerateAccessToken(user.ID, user.Role, 24*time.Hour)
	if err != nil {
		return "", err
	}

	return token, nil
}
