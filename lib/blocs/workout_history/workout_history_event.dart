import 'package:equatable/equatable.dart';

sealed class WorkoutHistoryEvent extends Equatable {
  const WorkoutHistoryEvent();

  @override
  List<Object?> get props => [];
}

class WorkoutHistoryLoaded extends WorkoutHistoryEvent {
  const WorkoutHistoryLoaded();
}

class WorkoutHistoryRefreshed extends WorkoutHistoryEvent {
  const WorkoutHistoryRefreshed();
}

class WorkoutDeleted extends WorkoutHistoryEvent {
  final int workoutId;

  const WorkoutDeleted(this.workoutId);

  @override
  List<Object?> get props => [workoutId];
}
