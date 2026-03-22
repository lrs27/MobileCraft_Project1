import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('campus_crave.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Restaurants table
    await db.execute('''
CREATE TABLE restaurants(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  cuisine TEXT,
  priceLevel INTEGER,
  hours TEXT,
  isFavorite INTEGER DEFAULT 0
      )
    ''');

    // Meal logs table
    await db.execute('''
      CREATE TABLE meal_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        restaurantId INTEGER,
        cost REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (restaurantId) REFERENCES restaurants (id)
      )
    ''');

    // Favorites table
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        restaurantId INTEGER NOT NULL,
        emoji TEXT,
        note TEXT,
        FOREIGN KEY (restaurantId) REFERENCES restaurants (id)
      )
    ''');
  }

  // Close DB
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
