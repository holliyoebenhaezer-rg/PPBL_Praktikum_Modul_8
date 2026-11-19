// lib/pages/halaman_riwayat_sensor.dart
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/pembacaan_sensor.dart';

class HalamanRiwayatSensor extends StatefulWidget {
  final List<JenisSensorInfo> daftarInfo;

  const HalamanRiwayatSensor({super.key, required this.daftarInfo});

  @override
  State<HalamanRiwayatSensor> createState() => _HalamanRiwayatSensorState();
}

class _HalamanRiwayatSensorState extends State<HalamanRiwayatSensor> {
  late Future<List<PembacaanSensor>> _futureRiwayat;
  late Future<String> _futureStatusSiaga;

  @override
  void initState() {
    super.initState();
    _muatUlang();
  }

  void _muatUlang() {
    setState(() {
      _futureRiwayat = DatabaseHelper.instance.ambilSemuaPembacaan();
      _futureStatusSiaga =
          DatabaseHelper.instance.hitungStatusSiagaDariDatabase(widget.daftarInfo);
    });
  }

  JenisSensorInfo? _cariInfo(String kode) {
    for (final item in widget.daftarInfo) {
      if (item.kode == kode) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Sensor'),
        actions: [
          FutureBuilder<String>(
            future: _futureStatusSiaga,
            builder: (context, snap) {
              final status = snap.data ?? 'Aman';
              Color warna = Colors.green;
              if (status == 'Siaga') warna = Colors.red;
              if (status == 'Waspada') warna = Colors.orange;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Chip(
                    label: Text(
                      'Status: $status',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: warna,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<PembacaanSensor>>(
        future: _futureRiwayat,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final daftar = snapshot.data ?? [];
          if (daftar.isEmpty) {
            return const Center(
              child: Text('Belum ada riwayat pembacaan sensor.'),
            );
          }

          return ListView.builder(
            itemCount: daftar.length,
            itemBuilder: (context, index) {
              final item = daftar[index];
              final info = _cariInfo(item.jenisSensor);
              final labelJenis = info?.nama ?? item.jenisSensor;
              final satuan = info?.satuan ?? '';

              return Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  await DatabaseHelper.instance.hapusPembacaan(item.id!);
                  _muatUlang();
                },
                child: ListTile(
                  title: Text(
                    '$labelJenis • ${item.nilai.toStringAsFixed(1)} $satuan',
                  ),
                  subtitle: Text('${item.lokasiPos}\n${item.waktu}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.edit_note),
                  onTap: () async {
                    final ctrl =
                        TextEditingController(text: item.nilai.toString());
                    final nilaiBaru = await showDialog<double>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Koreksi Nilai Pembacaan'),
                        content: TextField(
                          controller: ctrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Nilai baru ($satuan)',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(
                              context,
                              double.tryParse(ctrl.text.trim()),
                            ),
                            child: const Text('Simpan'),
                          ),
                        ],
                      ),
                    );

                    if (nilaiBaru != null) {
                      await DatabaseHelper.instance.ubahPembacaan(
                        PembacaanSensor(
                          id: item.id,
                          jenisSensor: item.jenisSensor,
                          nilai: nilaiBaru,
                          lokasiPos: item.lokasiPos,
                          waktu: item.waktu,
                        ),
                      );
                      _muatUlang();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}