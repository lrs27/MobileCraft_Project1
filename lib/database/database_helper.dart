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
    image TEXT,
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
  price REAL NOT NULL,
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

//Settings table
await db.execute('''
CREATE TABLE settings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  weeklyBudget REAL DEFAULT 0
)
''');

// Insert default settings row
await db.insert('settings', {
  'weeklyBudget': 0,
});

// ------------------ SEED RESTAURANTS ------------------

await db.insert('restaurants', {
  'name': "Rosa's Pizza",
  'cuisine': 'Pizza',
  'priceLevel': 1,
  'distance': 0.3,
  'hours': '10:00 AM - 10:00 PM',
  'image': 'lib/assets/images/rosa_pizza.jpg',
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
  'image': 'lib/assets/images/amalfi.jpg',
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
  'image': 'lib/assets/images/panda_express.jpg',
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
  'image': 'lib/assets/images/hibachi.jpg',
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
  'image': 'lib/assets/images/pho.jpg',
  'phone': '404-000-0000',
  'address': '18 Park Pl NE, Atlanta, GA 30303',
  'description': 'Pho, banh mi, and rice bowls.',
  'rating': 4.2,
  'lat': 33.755500,
  'lng': -84.387100,
});

await db.insert('restaurants', {
  'name': "Moe's Southwest Grill",
  'cuisine': 'Mexican',
  'priceLevel': 1,
  'distance': 0.1,
  'hours': '10:30 AM - 9:00 PM',
  'image': 'lib/assets/images/moes.jpg',
  'phone': '404-000-0000',
  'address': '66 Courtland St SE, Atlanta, GA 30303',
  'description': 'Burritos, bowls, tacos, and queso.',
  'rating': 4.0,
  'lat': 33.754900,
  'lng': -84.385700,
});

await db.insert('restaurants', {
  'name': 'Tin Lizzy’s Cantina',
  'cuisine': 'Mexican',
  'priceLevel': 2,
  'distance': 0.6,
  'hours': '11:00 AM - 10:00 PM',
  'image': 'lib/assets/images/tin_lizzy.jpg',
  'phone': '404-000-0000',
  'address': '26 Park Pl NE, Atlanta, GA 30303',
  'description': 'Tex-Mex tacos, skillets, and margaritas.',
  'rating': 4.2,
  'lat': 33.755700,
  'lng': -84.387300,
});

await db.insert('restaurants', {
  'name': 'Hungry AF Downtown',
  'cuisine': 'American',
  'priceLevel': 2,
  'distance': 0.2,
  'hours': '11:00 AM - 12:00 AM',
  'image': 'lib/assets/images/hungryaf.jpg',
  'phone': '404-000-0000',
  'address': '27 Piedmont Ave NE D1, Atlanta, GA 30303',
  'description': 'Comfort food with huge portions.',
  'rating': 4.7,
  'lat': 33.755302,
  'lng': -84.382053,
});

await db.insert('restaurants', {
  'name': 'Metro Diner & Bar',
  'cuisine': 'American',
  'priceLevel': 1,
  'distance': 0.5,
  'hours': 'Open until 4 AM',
  'image': 'lib/assets/images/metro.jpg',
  'phone': '404-000-0000',
  'address': '229 Peachtree St B17, Atlanta, GA 30303',
  'description': 'Classic diner food with a full bar.',
  'rating': 4.0,
  'lat': 33.759767,
  'lng': -84.386210,
});

await db.insert('restaurants', {
  'name': 'Mr. Fries Man',
  'cuisine': 'American',
  'priceLevel': 1,
  'distance': 0.1,
  'hours': '10:00 AM - 5:00 AM',
  'image': 'lib/assets/images/mrfries.jpg',
  'phone': '404-254-4381',
  'address': '30 Decatur St SE, Atlanta, GA 30303',
  'description': 'Loaded fries with customizable toppings.',
  'rating': 4.4,
  'lat': 33.753858,
  'lng': -84.388656,
});

await db.insert('restaurants', {
  'name': 'Chick-fil-A',
  'cuisine': 'American',
  'priceLevel': 1,
  'distance': 0.1,
  'hours': '7:00 AM - 9:00 PM',
  'image': 'lib/assets/images/chickfila.jpg',
  'phone': '404-000-0000',
  'address': '55 Gilmer St SE, Atlanta, GA 30303',
  'description': 'Chicken sandwiches, nuggets, and waffle fries.',
  'rating': 4.5,
  'lat': 33.754650,
  'lng': -84.385850,
});

await db.insert('restaurants', {
  'name': 'Broad Street Café',
  'cuisine': 'Cafe',
  'priceLevel': 1,
  'distance': 0.3,
  'hours': '8:00 AM - 4:00 PM',
  'image': 'lib/assets/images/broad.jpg',
  'phone': '404-000-0000',
  'address': '60 Broad St NW, Atlanta, GA 30303',
  'description': 'Sandwiches, breakfast, and coffee.',
  'rating': 4.1,
  'lat': 33.755800,
  'lng': -84.390300,
});

await db.insert('restaurants', {
  'name': 'Gusto!',
  'cuisine': 'American',
  'priceLevel': 2,
  'distance': 0.3,
  'hours': '10:30 AM - 8:00 PM',
  'image': 'lib/assets/images/gusto.jpg',
  'phone': '404-254-4197',
  'address': '193 Piedmont Ave NE, Atlanta, GA 30303',
  'description': 'Healthy bowls, wraps, and salads.',
  'rating': 4.6,
  'lat': 33.754900,
  'lng': -84.387200,
});

await db.insert('restaurants', {
  'name': 'Tin Drum Asian Kitchen',
  'cuisine': 'Cafe',
  'priceLevel': 2,
  'distance': 0.4,
  'hours': '11:00 AM - 9:00 PM',
  'image': 'lib/assets/images/tin_drum.jpg',
  'phone': '404-000-0000',
  'address': '75 Piedmont Ave NE, Atlanta, GA 30303',
  'description': 'Asian fusion bowls, noodles, and stir fry.',
  'rating': 4.2,
  'lat': 33.756400,
  'lng': -84.383700,
});

await db.insert('restaurants', {
  'name': 'Gyro Bros',
  'cuisine': 'American',
  'priceLevel': 1,
  'distance': 0.2,
  'hours': '11:00 AM - 9:00 PM',
  'image': 'lib/assets/images/gyro.jpg',
  'phone': '404-000-0000',
  'address': '85 Piedmont Ave NE, Atlanta, GA 30303',
  'description': 'Gyros, platters, falafel, and bowls.',
  'rating': 4.3,
  'lat': 33.756200,
  'lng': -84.383900,
});

// 🔥 EXPENSIVE RESTAURANTS NEAR GSU

await db.insert('restaurants', {
  'name': 'AG Steakhouse (Ritz-Carlton)',
  'cuisine': 'Steakhouse',
  'priceLevel': 3,
  'distance': 0.6,
  'hours': '5:00 PM - 10:00 PM',
  'image': 'lib/assets/images/ag_steakhouse.jpg',
  'phone': '404-221-6550',
  'address': '181 Peachtree St NE, Atlanta, GA 30303',
  'description': 'Upscale steakhouse inside the Ritz-Carlton featuring premium cuts and luxury dining.',
  'rating': 4.7,
  'lat': 33.759800,
  'lng': -84.387900,
});

await db.insert('restaurants', {
  'name': 'White Oak Kitchen & Cocktails',
  'cuisine': 'Southern',
  'priceLevel': 3,
  'distance': 0.5,
  'hours': '11:00 AM - 10:00 PM',
  'image': 'lib/assets/images/whiteoak.jpg',
  'phone': '404-524-7200',
  'address': '270 Peachtree St NW, Atlanta, GA 30303',
  'description': 'Modern Southern cuisine with craft cocktails in a stylish, upscale dining room.',
  'rating': 4.6,
  'lat': 33.760200,
  'lng': -84.387300,
});

await db.insert('restaurants', {
  'name': 'Ray’s in the City',
  'cuisine': 'Seafood',
  'priceLevel': 3,
  'distance': 0.7,
  'hours': '11:00 AM - 10:00 PM',
  'image': 'lib/assets/images/rays.jpg',
  'phone': '404-524-9224',
  'address': '240 Peachtree St NW, Atlanta, GA 30303',
  'description': 'High-end seafood restaurant known for fresh fish, sushi, and elegant ambiance.',
  'rating': 4.5,
  'lat': 33.760500,
  'lng': -84.387600,
});

await db.insert('restaurants', {
  'name': 'Cuts Steakhouse',
  'cuisine': 'Steakhouse',
  'priceLevel': 3,
  'distance': 0.4,
  'hours': '4:00 PM - 10:00 PM',
  'image': 'lib/assets/images/cuts.jpg',
  'phone': '404-525-3399',
  'address': '60 Andrew Young International Blvd NE, Atlanta, GA 30303',
  'description': 'Upscale steakhouse offering premium cuts, seafood, and fine dining near the GWCC.',
  'rating': 4.4,
  'lat': 33.759200,
  'lng': -84.387100,
});

await db.insert('restaurants', {
  'name': 'Polaris (Hyatt Regency)',
  'cuisine': 'American',
  'priceLevel': 3,
  'distance': 0.8,
  'hours': '5:00 PM - 11:00 PM',
  'image': 'lib/assets/images/polaris.jpg',
  'phone': '404-460-6425',
  'address': '265 Peachtree St NE, Atlanta, GA 30303',
  'description': 'Iconic rotating restaurant with skyline views and upscale American dishes.',
  'rating': 4.6,
  'lat': 33.760900,
  'lng': -84.386900,
});

await db.insert('restaurants', {
  'name': "Saxby's (GSU)",
  'cuisine': 'Cafe',
  'priceLevel': 1,
  'distance': 0.1,
  'hours': '7:00 AM - 7:00 PM',
  'image': 'lib/assets/images/saxbys.jpg',
  'phone': '404-413-9500',
  'address': '66 Courtland St SE, Atlanta, GA 30303',
  'description': 'Student-run café inside GSU offering coffee, sandwiches, smoothies, and study-friendly vibes.',
  'rating': 4.5,
  'lat': 33.753800,
  'lng': -84.385600,
});

await db.insert('restaurants', {
  'name': 'NaanStop',
  'cuisine': 'Indian',
  'priceLevel': 2,
  'distance': 0.4,
  'hours': '11:00 AM - 9:00 PM',
  'image': 'lib/assets/images/naanstop.jpg',
  'phone': '404-343-1808',
  'address': '3420 Piedmont Rd NE, Atlanta, GA 30305',
  'description': 'Fast-casual Indian bowls, naan wraps, and classic curries with a modern twist.',
  'rating': 4.4,
  'lat': 33.760200,
  'lng': -84.387800,
});

await db.insert('restaurants', {
  'name': 'Botiwalla',
  'cuisine': 'Indian',
  'priceLevel': 2,
  'distance': 0.9,
  'hours': '11:00 AM - 10:00 PM',
  'image': 'lib/assets/images/botiwalla.jpg',
  'phone': '404-343-1808',
  'address': '675 Ponce De Leon Ave NE, Atlanta, GA 30308',
  'description': 'Indian street food inspired by Irani cafés — kebabs, rolls, and masala fries.',
  'rating': 4.5,
  'lat': 33.772100,
  'lng': -84.365800,
});

await db.insert('restaurants', {
  'name': 'Planet Bombay',
  'cuisine': 'Indian',
  'priceLevel': 2,
  'distance': 0.8,
  'hours': '11:00 AM - 10:00 PM',
  'image': 'lib/assets/images/planet_bombay.jpg',
  'phone': '404-688-0005',
  'address': '451 Moreland Ave NE, Atlanta, GA 30307',
  'description': 'Traditional Indian curries, biryanis, and tandoori dishes served in a cozy setting.',
  'rating': 4.3,
  'lat': 33.772900,
  'lng': -84.349900,
});

await db.insert('restaurants', {
  'name': 'Dunkin Donuts',
  'cuisine': 'Cafe',
  'priceLevel': 1,
  'distance': 0.1,
  'hours': '6:00 AM - 8:00 PM',
  'image': 'lib/assets/images/dunkin.jpg',
  'phone': '404-555-1234',
  'address': '66 Courtland St SE, Atlanta, GA 30303',
  'description': 'Popular campus spot for coffee, donuts, and breakfast sandwiches.',
  'rating': 4.0,
  'lat': 33.753900,
  'lng': -84.385700,
});

await db.insert('restaurants', {
  'name': 'Julianna’s Coffee & Crepes',
  'cuisine': 'Cafe',
  'priceLevel': 2,
  'distance': 0.6,
  'hours': '8:00 AM - 4:00 PM',
  'image': 'lib/assets/images/juliannas.jpg',
  'phone': '404-883-3406',
  'address': '775 Lake Ave NE, Atlanta, GA 30307',
  'description': 'European-style café serving sweet and savory crepes with artisan coffee.',
  'rating': 4.7,
  'lat': 33.767900,
  'lng': -84.357900,
});

await db.insert('restaurants', {
  'name': 'Condesa Coffee',
  'cuisine': 'Cafe',
  'priceLevel': 2,
  'distance': 0.7,
  'hours': '7:00 AM - 6:00 PM',
  'image': 'lib/assets/images/condensa.jpg',
  'phone': '404-524-5054',
  'address': '480 John Wesley Dobbs Ave NE, Atlanta, GA 30312',
  'description': 'Trendy café offering espresso drinks, pastries, and light bites near Old Fourth Ward.',
  'rating': 4.6,
  'lat': 33.759900,
  'lng': -84.372900,
});

}


Future close() async {
  final db = await instance.database;
  db.close();
}
}