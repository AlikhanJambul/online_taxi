package grpc

import (
	pb "online_taxi/gen/trip-service"
	"online_taxi/services/trip-service/internal/app/usecase"
	"online_taxi/services/trip-service/internal/domain"
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

func toTripResponse(trip *domain.Trip) *pb.TripResponse {
	var driverID string
	if trip.DriverID != nil {
		driverID = *trip.DriverID
	}
	return &pb.TripResponse{
		TripId:        trip.ID,
		PassengerId:   trip.PassengerID,
		DriverId:      driverID,
		Status:        parseStatus(trip.Status),
		PickupAddress: trip.PickupAddress,
		DestAddress:   trip.DestAddress,
		PickupLat:     trip.PickupLat,
		PickupLng:     trip.PickupLng,
		DestLat:       trip.DestLat,
		DestLng:       trip.DestLng,
		PriceKzt:      trip.PriceKZT,
	}
}
