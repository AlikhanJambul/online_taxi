package domain

import (
	"context"
	"time"
)

type FileStorage interface {
	GenerateUploadURL(ctx context.Context, bucketName, objectName string, expiry time.Duration) (string, error)
}
