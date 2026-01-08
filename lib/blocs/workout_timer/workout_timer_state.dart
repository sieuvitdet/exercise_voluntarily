import 'package:equatable/equatable.dart';
import '../../core/utils/duration_utils.dart';
import '../../data/models/workout_quality.dart';

enum WorkoutStatus {
  initial,
  running,
  onBreak,
  completed,
  saving,
}

class WorkoutTimerState extends Equatable {
  final WorkoutStatus status;
  final Duration elapsed;
  final DateTime? startTime;
  final DateTime? breakStartTime;
  final Duration totalBreakDuration;

  const WorkoutTimerState({
    this.status = WorkoutStatus.initial,
    this.elapsed = Duration.zero,
    this.startTime,
    this.breakStartTime,
    this.totalBreakDuration = Duration.zero,
  });

  bool get isRunning => status == WorkoutStatus.running;
  bool get isOnBreak => status == WorkoutStatus.onBreak;
  bool get isCompleted => status == WorkoutStatus.completed;
  bool get isSaving => status == WorkoutStatus.saving;
  bool get isInitial => status == WorkoutStatus.initial;
  bool get isActive => isRunning || isOnBreak;

  String get formattedTime => DurationUtils.formatMMSS(elapsed);

  WorkoutQuality get quality => WorkoutQuality.fromDuration(elapsed);

  WorkoutTimerState copyWith({
    WorkoutStatus? status,
    Duration? elapsed,
    DateTime? startTime,
    DateTime? breakStartTime,
    Duration? totalBreakDuration,
    bool clearBreakStartTime = false,
  }) {
    return WorkoutTimerState(
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      startTime: startTime ?? this.startTime,
      breakStartTime:
          clearBreakStartTime ? null : (breakStartTime ?? this.breakStartTime),
      totalBreakDuration: totalBreakDuration ?? this.totalBreakDuration,
    );
  }

  @override
  List<Object?> get props => [
        status,
        elapsed,
        startTime,
        breakStartTime,
        totalBreakDuration,
      ];
}
