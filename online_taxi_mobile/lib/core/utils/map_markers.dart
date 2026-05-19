import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MapMarkers {
  final Uint8List pickup;
  final Uint8List destination;
  final Uint8List car;
  const MapMarkers({required this.pickup, required this.destination, required this.car});
}

final mapMarkersProvider = FutureProvider<MapMarkers>((ref) async {
  final results = await Future.wait([
    _drawPickup(),
    _drawDestination(),
    _drawCar(),
  ]);
  return MapMarkers(pickup: results[0], destination: results[1], car: results[2]);
});

// Зелёный кружок — точка подачи
Future<Uint8List> _drawPickup() => _drawDot(
  fill:   const Color(0xFF4CAF50),
  border: Colors.white,
);

// Жёлтый кружок — точка назначения
Future<Uint8List> _drawDestination() => _drawDot(
  fill:   const Color(0xFFFFCC00),
  border: const Color(0xFF111111),
);

// Белый кружок с жёлтой точкой — машина
Future<Uint8List> _drawCar() async {
  const size = 60.0;
  const half = size / 2;

  final recorder = ui.PictureRecorder();
  final canvas   = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));

  // Тень
  canvas.drawCircle(
    const Offset(half, half + 3),
    half - 6,
    Paint()
      ..color     = Colors.black.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
  );

  // Белый фон
  canvas.drawCircle(const Offset(half, half), half - 6, Paint()..color = Colors.white);

  // Жёлтое кольцо
  canvas.drawCircle(
    const Offset(half, half), half - 6,
    Paint()
      ..color       = const Color(0xFFFFCC00)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 3.5,
  );

  // Маленькая жёлтая точка в центре (иконка такси)
  canvas.drawCircle(const Offset(half, half), 5, Paint()..color = const Color(0xFFFFCC00));

  final img   = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

Future<Uint8List> _drawDot({required Color fill, required Color border}) async {
  const size = 52.0;
  const half = size / 2;

  final recorder = ui.PictureRecorder();
  final canvas   = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));

  // Тень
  canvas.drawCircle(
    const Offset(half, half + 3),
    half - 6,
    Paint()
      ..color      = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
  );

  // Заливка
  canvas.drawCircle(const Offset(half, half), half - 6, Paint()..color = fill);

  // Граница
  canvas.drawCircle(
    const Offset(half, half), half - 6,
    Paint()
      ..color       = border
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 2.5,
  );

  // Белая точка в центре
  canvas.drawCircle(const Offset(half, half), 5, Paint()..color = Colors.white);

  final img   = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}
