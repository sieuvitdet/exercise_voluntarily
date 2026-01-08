import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/workout.dart';
import '../../data/repositories/workout_repository.dart';
import '../../core/utils/date_utils.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final WorkoutRepository _workoutRepository;

  StatisticsBloc({
    required WorkoutRepository workoutRepository,
  })  : _workoutRepository = workoutRepository,
        super(const StatisticsState()) {
    on<StatisticsLoaded>(_onLoaded);
    on<StatisticsRefreshed>(_onRefreshed);
  }

  Future<void> _onLoaded(
    StatisticsLoaded event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await _calculateStatistics(emit);
  }

  Future<void> _onRefreshed(
    StatisticsRefreshed event,
    Emitter<StatisticsState> emit,
  ) async {
    await _calculateStatistics(emit);
  }

  Future<void> _calculateStatistics(Emitter<StatisticsState> emit) async {
    try {
      final allWorkouts = await _workoutRepository.getAllWorkouts();
      final now = DateTime.now();

      // Total workouts
      final totalWorkouts = allWorkouts.length;

      // Average duration
      final averageDuration = _calculateAverageDuration(allWorkouts);

      // This month's workouts
      final thisMonthWorkouts = await _workoutRepository.getWorkoutsForMonth(
        now.year,
        now.month,
      );

      // Calculate streaks
      final streaks = _calculateStreaks(allWorkouts);

      emit(StatisticsState(
        totalWorkouts: totalWorkouts,
        averageDuration: averageDuration,
        currentStreak: streaks.current,
        longestStreak: streaks.longest,
        thisMonthWorkouts: thisMonthWorkouts.length,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Duration _calculateAverageDuration(List<Workout> workouts) {
    if (workouts.isEmpty) return Duration.zero;

    final totalSeconds = workouts.fold<int>(
      0,
      (sum, workout) => sum + workout.duration.inSeconds,
    );

    return Duration(seconds: totalSeconds ~/ workouts.length);
  }

  ({int current, int longest}) _calculateStreaks(List<Workout> workouts) {
    if (workouts.isEmpty) return (current: 0, longest: 0);

    // Sort workouts by date (newest first is default from repository)
    final sortedWorkouts = List<Workout>.from(workouts)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Get unique workout dates
    final workoutDates = <DateTime>{};
    for (final workout in sortedWorkouts) {
      workoutDates.add(AppDateUtils.startOfDay(workout.date));
    }

    final sortedDates = workoutDates.toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) return (current: 0, longest: 0);

    // Calculate current streak
    int currentStreak = 0;
    final today = AppDateUtils.startOfDay(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    // Check if there's a workout today or yesterday to start the streak
    if (sortedDates.isNotEmpty) {
      final firstDate = sortedDates.first;
      if (AppDateUtils.isSameDay(firstDate, today) ||
          AppDateUtils.isSameDay(firstDate, yesterday)) {
        currentStreak = 1;
        DateTime expectedDate = firstDate.subtract(const Duration(days: 1));

        for (int i = 1; i < sortedDates.length; i++) {
          if (AppDateUtils.isSameDay(sortedDates[i], expectedDate)) {
            currentStreak++;
            expectedDate = expectedDate.subtract(const Duration(days: 1));
          } else {
            break;
          }
        }
      }
    }

    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 1;

    for (int i = 0; i < sortedDates.length - 1; i++) {
      final currentDate = sortedDates[i];
      final nextDate = sortedDates[i + 1];
      final daysDiff = AppDateUtils.daysBetween(nextDate, currentDate);

      if (daysDiff == 1) {
        tempStreak++;
      } else {
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
        tempStreak = 1;
      }
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    return (current: currentStreak, longest: longestStreak);
  }
}
