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

Future<Uint8List> _drawPickup() => _drawPin(const Color(0xFF1B5E20), Colors.white);
Future<Uint8List> _drawDestination() => _drawPin(const Color(0xFF0D47A1), Colors.white);

// Круглая иконка такси — жёлтый круг с чёрной машиной
Future<Uint8List> _drawCar() async {
  const size = 72.0;
  const cx   = size / 2;
  const r    = 30.0;

  final recorder = ui.PictureRecorder();
  final canvas   = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));

  // Чёрный обод
  canvas.drawCircle(
    const Offset(cx, cx),
    r + 3,
    Paint()..color = Colors.black,
  );

  // Жёлтая заливка
  canvas.drawCircle(
    const Offset(cx, cx),
    r,
    Paint()..color = const Color(0xFFFFD600),
  );

  // Кузов машины
  final body = Paint()..color = Colors.black;

  // Нижняя часть кузова
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(cx, cx + 6), width: 34, height: 13),
      const Radius.circular(4),
    ),
    body,
  );

  // Крыша
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(cx, cx - 3), width: 22, height: 11),
      const Radius.circular(3),
    ),
    body,
  );

  // Окна (жёлтые прямоугольники в крыше)
  final window = Paint()..color = const Color(0xFFFFD600);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 9, cx - 8, 8, 6),
      const Radius.circular(1),
    ),
    window,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(cx + 1, cx - 8, 8, 6),
      const Radius.circular(1),
    ),
    window,
  );

  // Колёса
  final wheel = Paint()..color = Colors.black;
  canvas.drawCircle(Offset(cx - 11, cx + 13), 5, wheel);
  canvas.drawCircle(Offset(cx + 11, cx + 13), 5, wheel);
  // Желтые центры колёс
  final hub = Paint()..color = const Color(0xFFFFD600);
  canvas.drawCircle(Offset(cx - 11, cx + 13), 2.5, hub);
  canvas.drawCircle(Offset(cx + 11, cx + 13), 2.5, hub);

  final img   = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

// Булавка с чётким контуром без прозрачностей
Future<Uint8List> _drawPin(Color fill, Color dot) async {
  const size  = 56.0;
  const cx    = size / 2;
  const r     = 20.0;
  const tipY  = size - 4.0;

  final recorder = ui.PictureRecorder();
  final canvas   = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));

  // Чёрный контур треугольника (хвост)
  final tailBorder = Path()
    ..moveTo(cx - 10, r + 2)
    ..lineTo(cx + 10, r + 2)
    ..lineTo(cx, tipY + 2)
    ..close();
  canvas.drawPath(tailBorder, Paint()..color = Colors.black);

  // Чёрный контур круга
  canvas.drawCircle(const Offset(cx, r), r + 2, Paint()..color = Colors.black);

  // Цветной хвост
  final tail = Path()
    ..moveTo(cx - 9, r + 2)
    ..lineTo(cx + 9, r + 2)
    ..lineTo(cx, tipY)
    ..close();
  canvas.drawPath(tail, Paint()..color = fill);

  // Цветной круг
  canvas.drawCircle(const Offset(cx, r), r, Paint()..color = fill);

  // Белая точка в центре
  canvas.drawCircle(const Offset(cx, r), 8, Paint()..color = dot);
  // Чёрное кольцо вокруг точки
  canvas.drawCircle(
    const Offset(cx, r),
    8,
    Paint()
      ..color       = Colors.black
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 1.5,
  );

  final img   = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}
