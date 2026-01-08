import '../database/database_helper.dart';
import '../database/database_constants.dart';
import '../models/workout.dart';
import 'workout_repository.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final DatabaseHelper _databaseHelper;

  WorkoutRepositoryImpl(this._databaseHelper);

  @override
  Future<int> saveWorkout(Workout workout) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      DatabaseConstants.workoutsTable,
      workout.toMap(),
    );
  }

  @override
  Future<List<Workout>> getAllWorkouts() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.workoutsTable,
      orderBy: '${DatabaseConstants.columnStartTime} DESC',
    );
    return maps.map((map) => Workout.fromMap(map)).toList();
  }

  @override
  Future<List<Workout>> getWorkoutsInRange(DateTime start, DateTime end) async {
    final db = await _databaseHelper.database;
    final startDate = _formatDateOnly(start);
    final endDate = _formatDateOnly(end);

    final maps = await db.query(
      DatabaseConstants.workoutsTable,
      where: '${DatabaseConstants.columnDate} BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: '${DatabaseConstants.columnDate} ASC',
    );
    return maps.map((map) => Workout.fromMap(map)).toList();
  }

  @override
  Future<List<Workout>> getWorkoutsForMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);
    return getWorkoutsInRange(start, end);
  }

  @override
  Future<Workout?> getWorkoutById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseConstants.workoutsTable,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Workout.fromMap(maps.first);
  }

  @override
  Future<void> deleteWorkout(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseConstants.workoutsTable,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteAllWorkouts() async {
    final db = await _databaseHelper.database;
    await db.delete(DatabaseConstants.workoutsTable);
  }

  @override
  Future<int> getWorkoutCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.workoutsTable}',
    );
    return result.first['count'] as int;
  }

  String _formatDateOnly(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
