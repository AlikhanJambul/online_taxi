package minio

import (
	"context"
	"fmt"
	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
	"log"
	"online_taxi/services/driver-service/internal/domain"
	"time"
)

type fileStorage struct {
	client *minio.Client
}

func NewFileStorage(endpoint, accessKey, secretKey string) (domain.FileStorage, error) {
	minioClient, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(accessKey, secretKey, ""),
		Secure: false,
	})
	if err != nil {
		return nil, fmt.Errorf("ошибка инициализации клиента minio: %w", err)
	}

	ctx := context.Background()
	bucketName := "media"

	exists, err := minioClient.BucketExists(ctx, bucketName)
	if err != nil {
		return nil, fmt.Errorf("ошибка проверки бакета: %w", err)
	}

	if !exists {
		err = minioClient.MakeBucket(ctx, bucketName, minio.MakeBucketOptions{})
		if err != nil {
			return nil, fmt.Errorf("ошибка создания бакета: %w", err)
		}

		policy := fmt.Sprintf(`{"Version": "2012-10-17","Statement": [{"Action": ["s3:GetObject"],"Effect": "Allow","Principal": {"AWS": ["*"]},"Resource": ["arn:aws:s3:::%s/*"]}]}`, bucketName)

		err = minioClient.SetBucketPolicy(ctx, bucketName, policy)
		if err != nil {
			return nil, fmt.Errorf("ошибка установки публичной политики: %w", err)
		}

		log.Printf("🔥 Бакет '%s' успешно создан и открыт для чтения!", bucketName)
	}

	return &fileStorage{client: minioClient}, nil
}

func (s *fileStorage) GenerateUploadURL(ctx context.Context, bucketName, objectName string, expiry time.Duration) (string, error) {
	url, err := s.client.PresignedPutObject(ctx, bucketName, objectName, expiry)
	if err != nil {
		return "", err
	}

	return url.String(), nil
}
