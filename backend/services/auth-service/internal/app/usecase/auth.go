package usecase

import (
	"context"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"online_taxi/services/auth-service/internal/domain"
	"online_taxi/services/pkg/jwt"
)

var instance string = "service:"

type Service interface {
	CreateUser(ctx context.Context, dto *RegisterRequestDTO) (*AuthResponseDTO, error)
	SaveSession(ctx context.Context, dto *LoginRequestDTO) (*AuthResponseDTO, error)
	ClearSession(ctx context.Context, dto *LogoutRequestDTO) error
	RefreshToken(ctx context.Context, dto *RefreshRequestDTO) (*RefreshResponseDTO, error)
}

type service struct {
	repo domain.Repository
	tm   *jwt.TokenManager
}

func NewService(repo domain.Repository, tm *jwt.TokenManager) Service {
	return &service{repo: repo, tm: tm}
}

func (s *service) CreateUser(ctx context.Context, dto *RegisterRequestDTO) (*AuthResponseDTO, error) {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(dto.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	uID := uuid.New()

	tokens, err := s.tm.GenerateTokenPair(uID.String(), string(dto.Role))
	if err != nil {
		return nil, err
	}

	user := domain.User{
		Phone:    dto.Phone,
		Email:    dto.Email,
		FullName: dto.FullName,
		Password: string(hashedPassword),
		Role:     dto.Role,
	}

	if err := s.repo.SaveUser(ctx, &user, tokens.RefreshToken, uID, dto.DeviceID); err != nil {
		return nil, err
	}

	response := AuthResponseDTO{
		AccessToken:  tokens.AccessToken,
		RefreshToken: tokens.RefreshToken,
		UserID:       uID.String(),
		Role:         dto.Role,
	}

	return &response, nil
}

func (s *service) SaveSession(ctx context.Context, dto *LoginRequestDTO) (*AuthResponseDTO, error) {
	user, err := s.repo.GetUserByEmail(ctx, dto.Email)
	if err != nil {
		return nil, domain.ErrInvalidEmailOrPassword
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(dto.Password))
	if err != nil {
		return nil, domain.ErrInvalidEmailOrPassword // TODO: custom
	}

	tokens, err := s.tm.GenerateTokenPair(user.ID.String(), user.Role)
	if err != nil {
		return nil, err
	}

	err = s.repo.SaveSession(ctx, user.ID.String(), tokens.RefreshToken, dto.DeviceID)
	if err != nil {
		return nil, err
	}

	return &AuthResponseDTO{
		RefreshToken: tokens.RefreshToken,
		AccessToken:  tokens.AccessToken,
		UserID:       user.ID.String(),
		Role:         user.Role,
	}, nil
}

func (s *service) ClearSession(ctx context.Context, dto *LogoutRequestDTO) error {
	return s.repo.ClearSession(ctx, dto.RefreshToken)
}

func (s *service) RefreshToken(ctx context.Context, dto *RefreshRequestDTO) (*RefreshResponseDTO, error) {
	user, err := s.repo.GetUserByDeviceID(ctx, dto.DeviceID) // TODO: Give the function a refresh token
	if err != nil {
		return nil, err
	}

	tokens, err := s.tm.GenerateTokenPair(user.ID.String(), user.Role)
	if err != nil {
		return nil, err
	}

	err = s.repo.SaveRefreshToken(ctx, tokens.RefreshToken, dto.DeviceID)
	if err != nil {
		return nil, err
	}

	return &RefreshResponseDTO{
		RefreshToken: tokens.RefreshToken,
		AccessToken:  tokens.AccessToken,
	}, nil

}
