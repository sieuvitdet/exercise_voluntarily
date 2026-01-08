import 'package:equatable/equatable.dart';

sealed class WorkoutTimerEvent extends Equatable {
  const WorkoutTimerEvent();

  @override
  List<Object?> get props => [];
}

class WorkoutStarted extends WorkoutTimerEvent {
  const WorkoutStarted();
}

class WorkoutTicked extends WorkoutTimerEvent {
  final Duration elapsed;

  const WorkoutTicked(this.elapsed);

  @override
  List<Object?> get props => [elapsed];
}

class WorkoutBreakToggled extends WorkoutTimerEvent {
  const WorkoutBreakToggled();
}

class WorkoutCompleted extends WorkoutTimerEvent {
  const WorkoutCompleted();
}

class WorkoutCancelled extends WorkoutTimerEvent {
  const WorkoutCancelled();
}

class WorkoutReset extends WorkoutTimerEvent {
  const WorkoutReset();
}
