package domain

import "context"

type Notification interface {
	SendPush(ctx context.Context, token, title, body string) error
	SendPushMulti(ctx context.Context, tokens []string, title, body string, data map[string]string) ([]string, error)
}
