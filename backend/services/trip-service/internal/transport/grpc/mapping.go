package grpc

import (
	pb "online_taxi/gen/trip-service"
	"online_taxi/services/trip-service/internal/app/usecase"
)

func toCreateDTO(req *pb.CreateTripRequest, userID string) usecase.CreateTripDTO {
	return usecase.CreateTripDTO{
		PassengerID:   userID,
		PickupAddress: req.PickupAddress,
		DestAddress:   req.DestAddress,
		PickupLat:     req.PickupLat,
		PickupLng:     req.PickupLng,
		DestLat:       req.DestLat,
		DestLng:       req.DestLng,
		PriceKZT:      req.PriceKzt,
	}
}

func toAcceptDTO(req *pb.AcceptTripRequest, userID string) usecase.AcceptTripDTO {
	return usecase.AcceptTripDTO{
		TripID:   req.TripId,
		DriverID: userID,
	}
}

func toEstimateDTO(req *pb.EstimateRequest) usecase.EstimatePriceReqDTO {
	return usecase.EstimatePriceReqDTO{
		PickupLat: req.PickupLat,
		PickupLng: req.PickupLng,
		DestLat:   req.DestLat,
		DestLng:   req.DestLng,
	}
}
