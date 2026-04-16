package usecase

import (
	"context"
	"online_taxi/services/driver-service/internal/domain"
)

type Service interface {
	CreateDriver(ctx context.Context, dto CreateRequestDTO) (*domain.Driver, error)
	GetDriver(ctx context.Context) (*domain.Driver, error)
}

type service struct {
	repo        domain.Repository
	fileStorage domain.FileStorage
}

func NewService(repo domain.Repository, fileStorage domain.FileStorage) Service {
	return &service{repo: repo, fileStorage: fileStorage}
}

func (s *service) CreateDriver(ctx context.Context, dto CreateRequestDTO) (*domain.Driver, error) {
	idAny := ctx.Value("userID")

	userID, ok := idAny.(string)
	if !ok || userID == "" {
		return nil, domain.ErrEmptyCtx
	}

	driver := &domain.Driver{
		UserID:       userID,
		CarColor:     dto.CarColor,
		CarModel:     dto.CarModel,
		CarMake:      dto.CarMake,
		LicensePlate: dto.LicensePlate,
	}

	status, err := s.repo.SaveDriver(ctx, driver)
	if err != nil {
		return nil, err
	}

	driver.Status = status

	return driver, nil
}

func (s *service) GetDriver(ctx context.Context) (*domain.Driver, error) {
	idAny := ctx.Value("userID")

	userID, ok := idAny.(string)
	if !ok || userID == "" {
		return nil, domain.ErrEmptyCtx
	}

	return s.repo.GetDriver(ctx, userID)
}
