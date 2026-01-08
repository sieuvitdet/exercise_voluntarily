import 'package:get_it/get_it.dart';
import '../data/database/database_helper.dart';
import '../data/repositories/workout_repository.dart';
import '../data/repositories/workout_repository_impl.dart';
import '../services/live_activity_service.dart';
import '../services/notification_service.dart';
import '../services/platform_timer_service.dart';
import '../blocs/workout_timer/workout_timer_bloc.dart';
import '../blocs/workout_history/workout_history_bloc.dart';
import '../blocs/statistics/statistics_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Database
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // Repositories
  getIt.registerLazySingleton<WorkoutRepository>(
    () => WorkoutRepositoryImpl(getIt<DatabaseHelper>()),
  );

  // Services
  getIt.registerLazySingleton<LiveActivityService>(() => LiveActivityService());
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<PlatformTimerService>(
    () => PlatformTimerService(
      liveActivityService: getIt<LiveActivityService>(),
      notificationService: getIt<NotificationService>(),
    ),
  );

  // BLoCs
  getIt.registerFactory<WorkoutTimerBloc>(
    () => WorkoutTimerBloc(
      workoutRepository: getIt<WorkoutRepository>(),
      timerService: getIt<PlatformTimerService>(),
    ),
  );

  getIt.registerFactory<WorkoutHistoryBloc>(
    () => WorkoutHistoryBloc(
      workoutRepository: getIt<WorkoutRepository>(),
    ),
  );

  getIt.registerFactory<StatisticsBloc>(
    () => StatisticsBloc(
      workoutRepository: getIt<WorkoutRepository>(),
    ),
  );
}
