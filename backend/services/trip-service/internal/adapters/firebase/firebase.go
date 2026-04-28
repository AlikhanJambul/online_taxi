package firebase

import (
	"context"
	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
	"online_taxi/services/trip-service/internal/domain"
)

type client struct {
	Messaging *messaging.Client
}

func New(credentialsPath string) (domain.Notification, error) {
	opt := option.WithCredentialsFile(credentialsPath)

	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		return nil, err
	}

	msgClient, err := app.Messaging(context.Background())
	if err != nil {
		return nil, err
	}

	return &client{Messaging: msgClient}, nil
}

func (c *client) SendPush(ctx context.Context, token, title, body string) error {
	_, err := c.Messaging.Send(ctx, &messaging.Message{
		Token: token,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
	})
	return err
}

func (c *client) SendPushMulti(ctx context.Context, tokens []string, title, body string) ([]string, error) {
	response, err := c.Messaging.SendEachForMulticast(ctx, &messaging.MulticastMessage{
		Tokens: tokens,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
	})
	if err != nil {
		return nil, err
	}

	// возвращаем протухшие токены — их надо удалить из sessions
	var deadTokens []string
	for i, r := range response.Responses {
		if !r.Success {
			deadTokens = append(deadTokens, tokens[i])
		}
	}

	return deadTokens, nil
}
