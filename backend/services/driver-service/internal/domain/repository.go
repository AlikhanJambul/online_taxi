package domain

import (
	"context"
)

type Repository interface {
	SaveDriver(ctx context.Context, driver *Driver) (string, error)
	GetDriver(ctx context.Context, id string) (*Driver, error)
}
