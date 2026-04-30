package minio

import (
	"context"
	"fmt"
	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
	"log"
	"time"
)

type FileStorage interface {
	GenerateUploadURL(ctx context.Context, bucketName, objectName string, expiry time.Duration) (string, error)
}

type fileStorage struct {
	client *minio.Client
}

func NewFileStorage(endpoint, accessKey, secretKey, bucketName string) (FileStorage, error) {
	minioClient, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(accessKey, secretKey, ""),
		Secure: false,
	})
	if err != nil {
		return nil, fmt.Errorf("ошибка инициализации клиента minio: %w", err)
	}

	if err := ensureBucket(minioClient, bucketName); err != nil {
		return nil, err
	}

	return &fileStorage{client: minioClient}, nil
}

func ensureBucket(client *minio.Client, bucketName string) error {
	ctx := context.Background()

	exists, err := client.BucketExists(ctx, bucketName)
	if err != nil {
		return fmt.Errorf("ошибка проверки бакета %s: %w", bucketName, err)
	}

	if !exists {
		err = client.MakeBucket(ctx, bucketName, minio.MakeBucketOptions{})
		if err != nil {
			return fmt.Errorf("ошибка создания бакета %s: %w", bucketName, err)
		}

		policy := fmt.Sprintf(`{
            "Version": "2012-10-17",
            "Statement": [{
                "Action": ["s3:GetObject"],
                "Effect": "Allow",
                "Principal": {"AWS": ["*"]},
                "Resource": ["arn:aws:s3:::%s/*"]
            }]
        }`, bucketName)

		if err = client.SetBucketPolicy(ctx, bucketName, policy); err != nil {
			return fmt.Errorf("ошибка установки политики для %s: %w", bucketName, err)
		}

		log.Printf("🔥 Бакет '%s' создан и открыт для чтения!", bucketName)
	}

	return nil
}

func (s *fileStorage) GenerateUploadURL(ctx context.Context, bucketName, objectName string, expiry time.Duration) (string, error) {
	url, err := s.client.PresignedPutObject(ctx, bucketName, objectName, expiry)
	if err != nil {
		return "", fmt.Errorf("ошибка генерации URL для %s/%s: %w", bucketName, objectName, err)
	}
	return url.String(), nil
}
