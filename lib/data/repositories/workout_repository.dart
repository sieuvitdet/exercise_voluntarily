import '../models/workout.dart';

abstract class WorkoutRepository {
  Future<int> saveWorkout(Workout workout);
  Future<List<Workout>> getAllWorkouts();
  Future<List<Workout>> getWorkoutsInRange(DateTime start, DateTime end);
  Future<List<Workout>> getWorkoutsForMonth(int year, int month);
  Future<Workout?> getWorkoutById(int id);
  Future<void> deleteWorkout(int id);
  Future<void> deleteAllWorkouts();
  Future<int> getWorkoutCount();
}
