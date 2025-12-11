import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/profile.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'profile.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profile(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        profession TEXT,
        contact TEXT,
        imagePath TEXT
      )
    ''');
  }

  Future<int> insertProfile(Profile profile) async {
    Database db = await database;
    return await db.insert('profile', profile.toMap());
  }

  Future<int> updateProfile(Profile profile) async {
    Database db = await database;
    return await db.update('profile', profile.toMap(),
        where: 'id = ?', whereArgs: [profile.id]);
  }

  Future<Profile?> getProfile() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('profile', limit: 1);
    if (maps.isNotEmpty) {
      return Profile.fromMap(maps.first);
    }
    return null;
  }
}
