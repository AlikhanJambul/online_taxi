import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../data/driver_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/provider/auth_provider.dart';

enum SetupStage { idle, uploadingAvatar, uploadingCar, creatingProfile, done, error }

class DriverSetupState {
  final SetupStage stage;
  final String?    error;

  const DriverSetupState({this.stage = SetupStage.idle, this.error});

  DriverSetupState copyWith({SetupStage? stage, String? error}) =>
      DriverSetupState(stage: stage ?? this.stage, error: error);
}

class DriverSetupNotifier extends StateNotifier<DriverSetupState> {
  final DriverRepository _driverRepo;
  final AuthRepository   _authRepo;
  final Ref              _ref;

  DriverSetupNotifier(this._driverRepo, this._authRepo, this._ref)
      : super(const DriverSetupState());

  Future<void> submitProfile({
    required File   avatarFile,
    required File   carFile,
    required String carMake,
    required String carModel,
    required String carColor,
    required String licensePlate,
  }) async {
    try {
      state = state.copyWith(stage: SetupStage.uploadingAvatar);
      final avatarInfo = await _authRepo.getAvatarUploadUrl();
      await _uploadFile(avatarInfo.uploadUrl, avatarFile);
      _ref.read(authProvider.notifier).setAvatarUrl(avatarInfo.fileUrl);

      state = state.copyWith(stage: SetupStage.uploadingCar);
      final carInfo = await _driverRepo.getCarUploadUrl();
      await _uploadFile(carInfo.uploadUrl, carFile);

      state = state.copyWith(stage: SetupStage.creatingProfile);
      await _driverRepo.createProfile(
        carMake:      carMake,
        carModel:     carModel,
        carColor:     carColor,
        licensePlate: licensePlate,
        carPhotoUrl:  carInfo.fileUrl,
      );

      state = state.copyWith(stage: SetupStage.done);
      _ref.read(authProvider.notifier).setDriverSetupStatus(DriverSetupStatus.pending);
    } catch (e) {
      state = DriverSetupState(
        stage: SetupStage.error,
        error: 'Ошибка: $e',
      );
    }
  }

Future<void> _uploadFile(String url, File file) async {
    final bytes    = await file.readAsBytes();
    final response = await http.put(
      Uri.parse(url),
      body:    bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка загрузки (${response.statusCode}): ${response.body}');
    }
  }

  void resetError() {
    if (state.stage == SetupStage.error) {
      state = const DriverSetupState();
    }
  }
}

final driverSetupProvider =
    StateNotifierProvider<DriverSetupNotifier, DriverSetupState>(
  (ref) => DriverSetupNotifier(
    ref.watch(driverRepositoryProvider),
    ref.watch(authRepositoryProvider),
    ref,
  ),
);
