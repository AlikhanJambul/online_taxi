package grpc

import (
	pb "online_taxi/gen/driver-service"
	"online_taxi/services/driver-service/internal/app/usecase"
)

func toCreateDTO(req *pb.CreateProfileRequest) usecase.CreateRequestDTO {
	return usecase.CreateRequestDTO{
		CarMake:      req.CarMake,
		CarModel:     req.CarModel,
		CarColor:     req.CarColor,
		LicensePlate: req.LicensePlate,
	}
}
