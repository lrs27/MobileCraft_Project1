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
  CREATE TABLE restaurants (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    cuisine TEXT NOT NULL,
    priceLevel INTEGER NOT NULL,
    distance REAL,
    hours TEXT,
    imageUrl TEXT,
    phone TEXT,
    address TEXT,
    description TEXT,
    rating REAL,
    lat REAL,
    lng REAL
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

  // Reviews table
  await db.execute('''
CREATE TABLE reviews(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  restaurantName TEXT,
  rating INTEGER,
  text TEXT
)
''');

// ------------------ SEED RESTAURANTS ------------------

await db.insert('restaurants', {
  'name': "Rosa's Pizza",
  'cuisine': 'Pizza',
  'priceLevel': 1,
  'distance': 0.3,
  'hours': '10:00 AM - 10:00 PM',
  'imageUrl': 'https://picsum.photos/400/501',
  'phone': '404-000-0000',
  'address': '62 Broad St NW, Atlanta, GA 30303',
  'description': 'NY-style slices, pasta, and quick service.',
  'rating': 4.4,
  'lat': 33.755900,
  'lng': -84.390500,
});

await db.insert('restaurants', {
  'name': 'Amalfi Cucina + Mercato',
  'cuisine': 'Pizza',
  'priceLevel': 2,
  'distance': 0.4,
  'hours': '11:00 AM - 10:00 PM',
  'imageUrl': 'https://picsum.photos/400/502',
  'phone': '404-000-0000',
  'address': '17 Andrew Young Intl Blvd NE, Atlanta, GA 30303',
  'description': 'Neapolitan-style pizzas and Italian classics.',
  'rating': 4.3,
  'lat': 33.759610,
  'lng': -84.386914,
});

await db.insert('restaurants', {
  'name': 'Panda Express',
  'cuisine': 'Chinese',
  'priceLevel': 1,
  'distance': 0.1,
  'hours': '10:30 AM - 9:00 PM',
  'imageUrl': 'https://picsum.photos/400/503',
  'phone': '404-000-0000',
  'address': '55 Gilmer St SE, Atlanta, GA 30303',
  'description': 'Fast Chinese-American bowls and plates.',
  'rating': 4.0,
  'lat': 33.754700,
  'lng': -84.385900,
});

await db.insert('restaurants', {
  'name': 'Hibachi Express',
  'cuisine': 'Chinese',
  'priceLevel': 1,
  'distance': 0.2,
  'hours': '11:00 AM - 10:00 PM',
  'imageUrl': 'https://picsum.photos/400/504',
  'phone': '404-000-0000',
  'address': '60 Broad St NW, Atlanta, GA 30303',
  'description': 'Quick hibachi bowls, fried rice, and teriyaki.',
  'rating': 4.3,
  'lat': 33.755900,
  'lng': -84.390200,
});

await db.insert('restaurants', {
  'name': 'Pho King Express',
  'cuisine': 'Asian',
  'priceLevel': 1,
  'distance': 0.4,
  'hours': '10:30 AM - 6:30 PM',
  'imageUrl': 'https://picsum.photos/400/505',
  'phone': '404-000-0000',
  'address': '18 Park Pl NE, Atlanta, GA 30303',
  'description': 'Pho, banh mi, and rice bowls.',
  'rating': 4.2,
  'lat': 33.755500,
  'lng': -84.387100,
});
}



Future close() async {
  final db = await instance.database;
  db.close();
}
}