import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('food_order.db');
    return _database!;
  }

  // Initializes the SQLite database with required tables.
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE food_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      cost REAL NOT NULL
    )
    ''');
    await db.execute('''
    CREATE TABLE order_plans (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      food_items TEXT NOT NULL,
      target_cost REAL NOT NULL
    )
    ''');

    // Prepopulate food items
    await db.insert('food_items', {'name': 'Burger', 'cost': 8.99});
    await db.insert('food_items', {'name': 'Pizza', 'cost': 10.99});
    await db.insert('food_items', {'name': 'Pasta', 'cost': 7.50});
    await db.insert('food_items', {'name': 'Salad', 'cost': 4.50});
    await db.insert('food_items', {'name': 'Soup', 'cost': 3.99});
    await db.insert('food_items', {'name': 'Steak', 'cost': 20.99});
    await db.insert('food_items', {'name': 'Chicken Sandwich', 'cost': 8.50});
    await db.insert('food_items', {'name': 'Tacos', 'cost': 6.99});
    await db.insert('food_items', {'name': 'Fries', 'cost': 2.99});
    await db.insert('food_items', {'name': 'Sushi', 'cost': 7.99});
    await db.insert('food_items', {'name': 'Ramen', 'cost': 5.99});
    await db.insert('food_items', {'name': 'Ice Cream', 'cost': 2.50});
    await db.insert('food_items', {'name': 'Donut', 'cost': 1.99});
    await db.insert('food_items', {'name': 'Coffee', 'cost': 2.50});
    await db.insert('food_items', {'name': 'Tea', 'cost': 1.99});
    await db.insert('food_items', {'name': 'Smoothie', 'cost': 5.99});
    await db.insert('food_items', {'name': 'Bagel', 'cost': 1.99});
    await db.insert('food_items', {'name': 'Cookie', 'cost': 1.00});
    await db.insert('food_items', {'name': 'Eggs', 'cost': 4.50});
    await db.insert('food_items', {'name': 'Waffles', 'cost': 6.00});
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Gets all food items from the database
  Future<List<Map<String, dynamic>>> fetchAllFoodItems() async {
    final db = await instance.database;
    return await db.query('food_items');
  }

  // Inserts a new order plan into the database
  Future<int> insertOrderPlan(Map<String, dynamic> orderPlan) async {
    final db = await instance.database;
    return await db.insert('order_plans', orderPlan);
  }

  // Queries order plans for a given date
  Future<List<Map<String, dynamic>>> fetchOrderPlansByDate(String date) async {
    final db = await instance.database;
    return await db.query('order_plans', where: 'date = ?', whereArgs: [date]);
  }

  // Updates an existing order plan in the database
  Future<int> updateOrderPlan(int id, Map<String, dynamic> orderPlan) async {
    final db = await instance.database;
    return await db.update('order_plans', orderPlan, where: 'id = ?', whereArgs: [id]);
  }

  // Deletes an order plan from the database by ID
  Future<int> deleteOrderPlan(int id) async {
    final db = await instance.database;
    return await db.delete('order_plans', where: 'id = ?', whereArgs: [id]);
  }
}
