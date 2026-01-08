import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/workout_repository.dart';
import '../../core/utils/date_utils.dart';
import 'workout_history_event.dart';
import 'workout_history_state.dart';

class WorkoutHistoryBloc
    extends Bloc<WorkoutHistoryEvent, WorkoutHistoryState> {
  final WorkoutRepository _workoutRepository;

  WorkoutHistoryBloc({
    required WorkoutRepository workoutRepository,
  })  : _workoutRepository = workoutRepository,
        super(const WorkoutHistoryInitial()) {
    on<WorkoutHistoryLoaded>(_onLoaded);
    on<WorkoutHistoryRefreshed>(_onRefreshed);
    on<WorkoutDeleted>(_onDeleted);
  }

  Future<void> _onLoaded(
    WorkoutHistoryLoaded event,
    Emitter<WorkoutHistoryState> emit,
  ) async {
    emit(const WorkoutHistoryLoading());

    try {
      await _loadWorkouts(emit);
    } catch (e) {
      emit(WorkoutHistoryFailure(e.toString()));
    }
  }

  Future<void> _onRefreshed(
    WorkoutHistoryRefreshed event,
    Emitter<WorkoutHistoryState> emit,
  ) async {
    try {
      await _loadWorkouts(emit);
    } catch (e) {
      emit(WorkoutHistoryFailure(e.toString()));
    }
  }

  Future<void> _onDeleted(
    WorkoutDeleted event,
    Emitter<WorkoutHistoryState> emit,
  ) async {
    try {
      await _workoutRepository.deleteWorkout(event.workoutId);
      await _loadWorkouts(emit);
    } catch (e) {
      emit(WorkoutHistoryFailure(e.toString()));
    }
  }

  Future<void> _loadWorkouts(Emitter<WorkoutHistoryState> emit) async {
    final allWorkouts = await _workoutRepository.getAllWorkouts();

    // Get last 30 days workouts for chart
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final last30Days = await _workoutRepository.getWorkoutsInRange(
      AppDateUtils.startOfDay(thirtyDaysAgo),
      AppDateUtils.endOfDay(now),
    );

    emit(WorkoutHistorySuccess(
      workouts: allWorkouts,
      last30DaysWorkouts: last30Days,
    ));
  }
}
