package driver_service

import (
	"google.golang.org/protobuf/protoadapt"
	"google.golang.org/protobuf/reflect/protoreflect"
)

// TripHistoryItemPb — v1-style proto message, encoded via struct tags.
type TripHistoryItemPb struct {
	Id            string `protobuf:"bytes,1,opt,name=id,proto3" json:"id,omitempty"`
	PickupAddress string `protobuf:"bytes,2,opt,name=pickup_address,json=pickupAddress,proto3" json:"pickup_address,omitempty"`
	DestAddress   string `protobuf:"bytes,3,opt,name=dest_address,json=destAddress,proto3" json:"dest_address,omitempty"`
	PriceKzt      int64  `protobuf:"varint,4,opt,name=price_kzt,json=priceKzt,proto3" json:"price_kzt,omitempty"`
	FinishedAt    string `protobuf:"bytes,5,opt,name=finished_at,json=finishedAt,proto3" json:"finished_at,omitempty"`
}

func (*TripHistoryItemPb) Reset()         {}
func (*TripHistoryItemPb) String() string  { return "" }
func (*TripHistoryItemPb) ProtoMessage()   {}

// tripHistoryResponseFields holds the actual proto fields for TripHistoryResponse.
// It is an unexported v1 type used by the legacy encoding bridge.
type tripHistoryResponseFields struct {
	Items []*TripHistoryItemPb `protobuf:"bytes,1,rep,name=items,proto3" json:"items,omitempty"`
}

func (*tripHistoryResponseFields) Reset()         {}
func (*tripHistoryResponseFields) String() string  { return "" }
func (*tripHistoryResponseFields) ProtoMessage()   {}

// TripHistoryResponse implements proto.Message (v2) via the golang/protobuf legacy bridge.
// Embedding tripHistoryResponseFields promotes the Items field so that both encoding
// and decoding write to the same memory.
type TripHistoryResponse struct {
	tripHistoryResponseFields
}

func (x *TripHistoryResponse) Reset()         { x.Items = nil }
func (x *TripHistoryResponse) String() string  { return "" }
func (x *TripHistoryResponse) ProtoMessage()   {}

func (x *TripHistoryResponse) ProtoReflect() protoreflect.Message {
	return protoadapt.MessageV2Of(&x.tripHistoryResponseFields).ProtoReflect()
}
