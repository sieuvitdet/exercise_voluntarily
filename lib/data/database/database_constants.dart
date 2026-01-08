class DatabaseConstants {
  DatabaseConstants._();

  static const String databaseName = 'fitness_on_u.db';
  static const int databaseVersion = 1;

  // Table names
  static const String workoutsTable = 'workouts';

  // Column names
  static const String columnId = 'id';
  static const String columnDate = 'date';
  static const String columnStartTime = 'start_time';
  static const String columnEndTime = 'end_time';
  static const String columnDurationSeconds = 'duration_seconds';
  static const String columnQuality = 'quality';
  static const String columnCreatedAt = 'created_at';
}
