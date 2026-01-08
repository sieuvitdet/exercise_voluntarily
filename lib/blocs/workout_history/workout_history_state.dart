import 'package:equatable/equatable.dart';
import '../../data/models/workout.dart';

sealed class WorkoutHistoryState extends Equatable {
  const WorkoutHistoryState();

  @override
  List<Object?> get props => [];
}

class WorkoutHistoryInitial extends WorkoutHistoryState {
  const WorkoutHistoryInitial();
}

class WorkoutHistoryLoading extends WorkoutHistoryState {
  const WorkoutHistoryLoading();
}

class WorkoutHistorySuccess extends WorkoutHistoryState {
  final List<Workout> workouts;
  final List<Workout> last30DaysWorkouts;

  const WorkoutHistorySuccess({
    required this.workouts,
    required this.last30DaysWorkouts,
  });

  bool get isEmpty => workouts.isEmpty;
  int get totalCount => workouts.length;

  @override
  List<Object?> get props => [workouts, last30DaysWorkouts];
}

class WorkoutHistoryFailure extends WorkoutHistoryState {
  final String message;

  const WorkoutHistoryFailure(this.message);

  @override
  List<Object?> get props => [message];
}
