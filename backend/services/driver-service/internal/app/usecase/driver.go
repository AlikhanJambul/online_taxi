package usecase

import (
	"context"
	"fmt"
	"github.com/google/uuid"
	"online_taxi/services/driver-service/internal/domain"
	"online_taxi/services/shared/minio"
	"time"
)

type Service interface {
	CreateDriver(ctx context.Context, dto CreateRequestDTO) (*domain.Driver, error)
	GetDriver(ctx context.Context) (*domain.Driver, error)
	GetCarUploadURL(ctx context.Context, expire time.Duration) (string, string, error)
}

type service struct {
	repo        domain.Repository
	fileStorage minio.FileStorage
	minioPort   string
}

func NewService(repo domain.Repository, fileStorage minio.FileStorage, minioPort string) Service {
	return &service{repo: repo, fileStorage: fileStorage, minioPort: minioPort}
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
	if !ok || userID == "'" {
		return nil, domain.ErrEmptyCtx
	}

	return s.repo.GetDriver(ctx, userID)
}

func (s *service) GetCarUploadURL(ctx context.Context, expiry time.Duration) (string, string, error) {
	str := uuid.New().String()

	objectName := fmt.Sprintf("%s/cars.jpg", str)

	uploadURL, err := s.fileStorage.GenerateUploadURL(ctx, "cars", objectName, expiry)
	if err != nil {
		return "", "", err
	}

	// TODO: Нужно менять на ip компа
	fileURL := fmt.Sprintf("http://minio:%s/cars/%s", s.minioPort, objectName)

	return uploadURL, fileURL, nil
}
