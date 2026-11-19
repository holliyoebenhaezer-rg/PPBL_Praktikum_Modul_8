// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/sensor_cubit.dart';
import 'cubit/theme_cubit.dart';
import 'pages/dashboard_sensor_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AiotPeringatanDiniApp());
}

class AiotPeringatanDiniApp extends StatelessWidget {
  const AiotPeringatanDiniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SensorCubit()),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'AIoT Peringatan Dini Bencana',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const DashboardSensorPage(),
          );
        },
      ),
    );
  }
}