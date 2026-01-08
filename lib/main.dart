import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'di/injection_container.dart';
import 'services/platform_timer_service.dart';
import 'data/database/database_helper.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1E3C72),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize dependencies
  await setupDependencies();

  // Initialize database
  await getIt<DatabaseHelper>().database;

  // Initialize platform services
  await getIt<PlatformTimerService>().init();

  runApp(const FitnessApp());
}
