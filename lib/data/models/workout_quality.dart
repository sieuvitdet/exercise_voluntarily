import 'dart:ui';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_durations.dart';

enum WorkoutQuality {
  casual(
    label: AppStrings.casualWorkout,
    color: AppColors.qualityCasual,
  ),
  good(
    label: AppStrings.goodWorkout,
    color: AppColors.qualityGood,
  ),
  excellent(
    label: AppStrings.excellentWorkout,
    color: AppColors.qualityExcellent,
  );

  final String label;
  final Color color;

  const WorkoutQuality({
    required this.label,
    required this.color,
  });

  static WorkoutQuality fromDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < AppDurations.casualMaxMinutes) {
      return WorkoutQuality.casual;
    } else if (minutes < AppDurations.goodMaxMinutes) {
      return WorkoutQuality.good;
    } else {
      return WorkoutQuality.excellent;
    }
  }

  static WorkoutQuality fromString(String value) {
    return WorkoutQuality.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WorkoutQuality.casual,
    );
  }
}
