import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'di/injection_container.dart';
import 'blocs/workout_timer/workout_timer_bloc.dart';
import 'blocs/workout_history/workout_history_bloc.dart';
import 'blocs/workout_history/workout_history_event.dart';
import 'blocs/statistics/statistics_bloc.dart';
import 'blocs/statistics/statistics_event.dart';
import 'presentation/screens/home_screen.dart';

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WorkoutTimerBloc>(
          create: (_) => getIt<WorkoutTimerBloc>(),
        ),
        BlocProvider<WorkoutHistoryBloc>(
          create: (_) => getIt<WorkoutHistoryBloc>()
            ..add(const WorkoutHistoryLoaded()),
        ),
        BlocProvider<StatisticsBloc>(
          create: (_) => getIt<StatisticsBloc>()..add(const StatisticsLoaded()),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
