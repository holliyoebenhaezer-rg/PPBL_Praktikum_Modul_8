// lib/pages/dashboard_sensor_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/sensor_cubit.dart';
import '../db/database_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../widgets/sensor_card.dart';
import '../widgets/theme_toggle_button.dart';
import 'halaman_riwayat_sensor.dart';

class DashboardSensorPage extends StatelessWidget {
  const DashboardSensorPage({super.key});

  static const daftarSensor = [
    JenisSensorInfo(
      kode: 'ketinggian_air',
      nama: 'Ketinggian Air Sungai',
      satuan: 'cm',
      lokasiDefault: 'Pos Sungai Citarum Hulu',
      batasWaspada: 150,
      batasSiaga: 250,
    ),
    JenisSensorInfo(
      kode: 'pergeseran_tanah',
      nama: 'Pergeseran Tanah',
      satuan: 'mm',
      lokasiDefault: 'Pos Lereng Pasirjambu',
      batasWaspada: 15,
      batasSiaga: 30,
    ),
    JenisSensorInfo(
      kode: 'curah_hujan',
      nama: 'Curah Hujan',
      satuan: 'mm/jam',
      lokasiDefault: 'Pos Stasiun Hujan Ciwidey',
      batasWaspada: 40,
      batasSiaga: 75,
    ),
  ];

  Future<void> _simpanPembacaan(
    BuildContext context,
    JenisSensorInfo info,
    double nilai,
    String lokasi,
  ) async {
    context.read<SensorCubit>().perbaruiNilai(info.kode, nilai);
    await DatabaseHelper.instance.tambahPembacaan(
      PembacaanSensor(
        jenisSensor: info.kode,
        nilai: nilai,
        lokasiPos: lokasi,
        waktu: DateTime.now().toString(),
      ),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tersimpan ke SQLite: ${info.nama} (${nilai.toStringAsFixed(1)} ${info.satuan})',
        ),
      ),
    );
  }

  Future<void> _bukaDialogManual(
    BuildContext context,
    JenisSensorInfo info,
    double nilaiAwal,
  ) async {
    final nilaiController =
        TextEditingController(text: nilaiAwal.toStringAsFixed(1));
    final lokasiController = TextEditingController(text: info.lokasiDefault);

    final hasil = await showDialog<(double, String)?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Input Manual - ${info.nama}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nilaiController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Nilai (${info.satuan})',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: lokasiController,
              decoration: const InputDecoration(
                labelText: 'Lokasi Pos Pemantauan',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final parsed = double.tryParse(nilaiController.text.trim());
              final lokasi = lokasiController.text.trim().isEmpty
                  ? info.lokasiDefault
                  : lokasiController.text.trim();
              if (parsed != null) {
                Navigator.pop(context, (parsed, lokasi));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (hasil != null && context.mounted) {
      await _simpanPembacaan(context, info, hasil.$1, hasil.$2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rng = Random();
    return Scaffold(
      appBar: AppBar(
        title: const Text('AIoT Peringatan Dini Bencana'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Sensor',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const HalamanRiwayatSensor(daftarInfo: daftarSensor),
                ),
              );
            },
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: BlocBuilder<SensorCubit, SensorLiveState>(
        builder: (context, liveState) {
          final nilaiMap = {
            'ketinggian_air': liveState.ketinggianAir,
            'pergeseran_tanah': liveState.pergeseranTanah,
            'curah_hujan': liveState.curahHujan,
          };

          return ListView.builder(
            itemCount: daftarSensor.length,
            itemBuilder: (context, index) {
              final info = daftarSensor[index];
              final nilaiSaatIni = nilaiMap[info.kode] ?? 0;
              final nilaiSimulasi =
                  double.parse((nilaiSaatIni + rng.nextInt(35) - 10).clamp(1, 320).toStringAsFixed(1));

              return SensorCard(
                info: info,
                nilaiSaatIni: nilaiSaatIni,
                onSimulasi: () => _simpanPembacaan(
                  context,
                  info,
                  nilaiSimulasi,
                  info.lokasiDefault,
                ),
                onInputManual: () =>
                    _bukaDialogManual(context, info, nilaiSaatIni),
              );
            },
          );
        },
      ),
    );
  }
}