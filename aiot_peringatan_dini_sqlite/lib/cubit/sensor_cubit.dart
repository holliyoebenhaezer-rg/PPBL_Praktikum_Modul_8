// lib/cubit/sensor_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class SensorLiveState {
  final double ketinggianAir;   // cm
  final double pergeseranTanah; // mm
  final double curahHujan;      // mm/jam

  const SensorLiveState({
    this.ketinggianAir = 85.0,
    this.pergeseranTanah = 4.5,
    this.curahHujan = 12.0,
  });

  SensorLiveState copyWith({
    double? ketinggianAir,
    double? pergeseranTanah,
    double? curahHujan,
  }) {
    return SensorLiveState(
      ketinggianAir: ketinggianAir ?? this.ketinggianAir,
      pergeseranTanah: pergeseranTanah ?? this.pergeseranTanah,
      curahHujan: curahHujan ?? this.curahHujan,
    );
  }
}

class SensorCubit extends Cubit<SensorLiveState> {
  SensorCubit() : super(const SensorLiveState());

  void perbaruiNilai(String jenisSensor, double nilaiBaru) {
    switch (jenisSensor) {
      case 'ketinggian_air':
        emit(state.copyWith(ketinggianAir: nilaiBaru));
        break;
      case 'pergeseran_tanah':
        emit(state.copyWith(pergeseranTanah: nilaiBaru));
        break;
      case 'curah_hujan':
        emit(state.copyWith(curahHujan: nilaiBaru));
        break;
    }
  }
}