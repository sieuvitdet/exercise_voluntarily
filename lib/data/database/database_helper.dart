import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_constants.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DatabaseConstants.databaseName);

    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.workoutsTable} (
        ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.columnDate} TEXT NOT NULL,
        ${DatabaseConstants.columnStartTime} TEXT NOT NULL,
        ${DatabaseConstants.columnEndTime} TEXT NOT NULL,
        ${DatabaseConstants.columnDurationSeconds} INTEGER NOT NULL,
        ${DatabaseConstants.columnQuality} TEXT NOT NULL CHECK (${DatabaseConstants.columnQuality} IN ('casual', 'good', 'excellent')),
        ${DatabaseConstants.columnCreatedAt} TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_workouts_date ON ${DatabaseConstants.workoutsTable}(${DatabaseConstants.columnDate})
    ''');

    await db.execute('''
      CREATE INDEX idx_workouts_quality ON ${DatabaseConstants.workoutsTable}(${DatabaseConstants.columnQuality})
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here when schema changes
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
