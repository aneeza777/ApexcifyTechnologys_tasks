import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/workout.dart';
import '../models/bmi_entry.dart';
import '../models/step_entry.dart';

class SQLiteService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'fitness_app.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workouts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        calories INTEGER,
        minutes INTEGER,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE bmi_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        value REAL,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE steps(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        count INTEGER,
        date TEXT
      )
    ''');
  }

  // Insert Workout
  Future<int> insertWorkout(Workout workout) async {
    final db = await database;
    return await db.insert('workouts', {
      'name': workout.name,
      'calories': workout.calories,
      'minutes': workout.minutes,
      'date': workout.date.toIso8601String(),
    });
  }

  // Update Workout
  Future<int> updateWorkout(int id, Workout workout) async {
    final db = await database;
    return await db.update('workouts', {
      'name': workout.name,
      'calories': workout.calories,
      'minutes': workout.minutes,
      'date': workout.date.toIso8601String(),
    }, where: 'id = ?', whereArgs: [id]);
  }

  // Delete Workout
  Future<int> deleteWorkout(int id) async {
    final db = await database;
    return await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

// Similar methods can be created for BMIEntry and StepEntry
}
