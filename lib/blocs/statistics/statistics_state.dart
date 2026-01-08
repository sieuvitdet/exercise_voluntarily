import 'package:equatable/equatable.dart';
import '../../core/utils/duration_utils.dart';

class StatisticsState extends Equatable {
  final int totalWorkouts;
  final Duration averageDuration;
  final int currentStreak;
  final int longestStreak;
  final int thisMonthWorkouts;
  final bool isLoading;

  const StatisticsState({
    this.totalWorkouts = 0,
    this.averageDuration = Duration.zero,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.thisMonthWorkouts = 0,
    this.isLoading = false,
  });

  String get formattedAverageDuration =>
      DurationUtils.formatReadable(averageDuration);

  StatisticsState copyWith({
    int? totalWorkouts,
    Duration? averageDuration,
    int? currentStreak,
    int? longestStreak,
    int? thisMonthWorkouts,
    bool? isLoading,
  }) {
    return StatisticsState(
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      averageDuration: averageDuration ?? this.averageDuration,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      thisMonthWorkouts: thisMonthWorkouts ?? this.thisMonthWorkouts,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        totalWorkouts,
        averageDuration,
        currentStreak,
        longestStreak,
        thisMonthWorkouts,
        isLoading,
      ];
}
