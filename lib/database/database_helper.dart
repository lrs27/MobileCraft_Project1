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

  // Reviews table
  await db.execute('''
CREATE TABLE reviews(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  restaurantName TEXT,
  rating INTEGER,
  text TEXT
)
''');
}
