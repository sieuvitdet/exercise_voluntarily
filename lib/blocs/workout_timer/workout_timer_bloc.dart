import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/workout.dart';
import '../../data/repositories/workout_repository.dart';
import '../../services/platform_timer_service.dart';
import 'workout_timer_event.dart';
import 'workout_timer_state.dart';

class WorkoutTimerBloc extends Bloc<WorkoutTimerEvent, WorkoutTimerState> {
  final WorkoutRepository _workoutRepository;
  final PlatformTimerService _timerService;
  StreamSubscription<int>? _tickerSubscription;
  Timer? _timer;

  WorkoutTimerBloc({
    required WorkoutRepository workoutRepository,
    required PlatformTimerService timerService,
  })  : _workoutRepository = workoutRepository,
        _timerService = timerService,
        super(const WorkoutTimerState()) {
    on<WorkoutStarted>(_onStarted);
    on<WorkoutTicked>(_onTicked);
    on<WorkoutBreakToggled>(_onBreakToggled);
    on<WorkoutCompleted>(_onCompleted);
    on<WorkoutCancelled>(_onCancelled);
    on<WorkoutReset>(_onReset);
  }

  Future<void> _onStarted(
    WorkoutStarted event,
    Emitter<WorkoutTimerState> emit,
  ) async {
    final startTime = DateTime.now();

    emit(state.copyWith(
      status: WorkoutStatus.running,
      startTime: startTime,
      elapsed: Duration.zero,
      totalBreakDuration: Duration.zero,
      clearBreakStartTime: true,
    ));

    // Start the timer first (most important)
    _startTimer();

    // Start Live Activity (non-blocking, fire and forget)
    _timerService.startActivity(startTime);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isRunning && state.startTime != null) {
        final now = DateTime.now();
        final totalElapsed = now.difference(state.startTime!);
        final actualElapsed = totalElapsed - state.totalBreakDuration;
        add(WorkoutTicked(actualElapsed));
      }
    });
  }

  Future<void> _onTicked(
    WorkoutTicked event,
    Emitter<WorkoutTimerState> emit,
  ) async {
    emit(state.copyWith(elapsed: event.elapsed));
    // Update Live Activity (non-blocking)
    _timerService.updateActivity(event.elapsed, isOnBreak: false);
  }

  Future<void> _onBreakToggled(
    WorkoutBreakToggled event,
    Emitter<WorkoutTimerState> emit,
  ) async {
    if (state.isRunning) {
      // Going on break
      emit(state.copyWith(
        status: WorkoutStatus.onBreak,
        breakStartTime: DateTime.now(),
      ));
      _timerService.updateActivity(state.elapsed, isOnBreak: true);
    } else if (state.isOnBreak) {
      // Resuming from break
      final breakDuration = state.breakStartTime != null
          ? DateTime.now().difference(state.breakStartTime!)
          : Duration.zero;

      emit(state.copyWith(
        status: WorkoutStatus.running,
        totalBreakDuration: state.totalBreakDuration + breakDuration,
        clearBreakStartTime: true,
      ));
      _timerService.updateActivity(state.elapsed, isOnBreak: false);
    }
  }

  Future<void> _onCompleted(
    WorkoutCompleted event,
    Emitter<WorkoutTimerState> emit,
  ) async {
    _timer?.cancel();
    _tickerSubscription?.cancel();

    emit(state.copyWith(status: WorkoutStatus.saving));

    final endTime = DateTime.now();

    if (state.startTime != null) {
      final workout = Workout.create(
        startTime: state.startTime!,
        endTime: endTime,
      ).copyWith(duration: state.elapsed);

      await _workoutRepository.saveWorkout(workout);
    }

    // End Live Activity (non-blocking)
    _timerService.endActivity();

    emit(state.copyWith(status: WorkoutStatus.completed));
  }

  Future<void> _onCancelled(
    WorkoutCancelled event,
    Emitter<WorkoutTimerState> emit,
  ) async {
    _timer?.cancel();
    _tickerSubscription?.cancel();

    // End Live Activity (non-blocking)
    _timerService.endActivity();

    emit(const WorkoutTimerState());
  }

  Future<void> _onReset(
    WorkoutReset event,
    Emitter<WorkoutTimerState> emit,
  ) async {
    _timer?.cancel();
    _tickerSubscription?.cancel();

    emit(const WorkoutTimerState());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _tickerSubscription?.cancel();
    return super.close();
  }
}
