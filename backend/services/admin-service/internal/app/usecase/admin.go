package usecase

import (
	"context"
	"online_taxi/services/admin-service/internal/domain"
)

type Service interface {
	GetUsers(ctx context.Context) ([]domain.User, error)
	AcceptDriver(ctx context.Context, dto AcceptDriverDTO) error
}

type service struct {
	repo domain.Repository
}

func NewService(repo domain.Repository) Service {
	return &service{repo: repo}
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
