// lib/widgets/sensor_card.dart
import 'package:flutter/material.dart';
import '../models/pembacaan_sensor.dart';

class SensorCard extends StatelessWidget {
  final JenisSensorInfo info;
  final double nilaiSaatIni;
  final VoidCallback onSimulasi;
  final VoidCallback onInputManual;

  const SensorCard({
    super.key,
    required this.info,
    required this.nilaiSaatIni,
    required this.onSimulasi,
    required this.onInputManual,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = info.tentukanStatus(nilaiSaatIni);

    Color badgeColor;
    if (status == 'Siaga') {
      badgeColor = Colors.red;
    } else if (status == 'Waspada') {
      badgeColor = Colors.orange;
    } else {
      badgeColor = Colors.green;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(info.nama, style: theme.textTheme.titleMedium),
                Chip(
                  label: Text(
                    status,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: badgeColor,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${nilaiSaatIni.toStringAsFixed(1)} ${info.satuan}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pos: ${info.lokasiDefault} (Waspada: ${info.batasWaspada}, Siaga: ${info.batasSiaga})',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onSimulasi,
                  icon: const Icon(Icons.sensors),
                  label: const Text('Simulasi & Simpan'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onInputManual,
                  icon: const Icon(Icons.edit),
                  label: const Text('Input Manual'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}