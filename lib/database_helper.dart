import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // 🔥 1. เปลี่ยนชื่อไฟล์ DB เป็นชื่อใหม่ (เพื่อบังคับสร้างตารางใหม่)
  static const _databaseName = 'calories_final.db'; 
  static const _databaseVersion = 1;

  // --- ตารางอาหาร ---
  static const tableFood = 'food'; // 🔥 2. แก้จาก 'food_data' เป็น 'food'
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnCalories = 'calories';
  static const columnDate = 'date';
  // (ถ้าไม่ได้เก็บรูปอาหาร ตัด columnImage ออกจากตารางอาหาร เพื่อลดบั๊ก)

  // --- ตารางผู้ใช้ ---
  static const tableUser = 'user_data';
  static const columnTarget = 'target_calories';
  static const columnImage = 'image_path';

  // Singleton Pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    // 1. สร้างตารางอาหาร
    // (ลบ columnImage ออกจาก Food ถ้าไม่ได้ถ่ายรูปอาหารทุกมื้อ)
    await db.execute('''
          CREATE TABLE $tableFood (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnName TEXT NOT NULL,
            $columnCalories INTEGER NOT NULL,
            $columnDate TEXT NOT NULL
          )
          ''');
    
    // 2. สร้างตารางผู้ใช้
    await db.execute('''
      CREATE TABLE $tableUser (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnTarget INTEGER NOT NULL,
        $columnImage TEXT
      )
    ''');
  }

  // ==========================================
  // ส่วนที่ 1: จัดการข้อมูลผู้ใช้ (User)
  // ==========================================
  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    await db.delete(tableUser); // ลบของเก่าก่อน
    return await db.insert(tableUser, row);
  }

  Future<Map<String, dynamic>?> getUser() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(tableUser);
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> updateUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.update(tableUser, row, where: '$columnId = ?', whereArgs: [1]);
  }

  // ==========================================
  // ส่วนที่ 2: จัดการข้อมูลอาหาร (Food)
  // ==========================================
  
  // เพิ่มอาหาร
  Future<int> insertFood(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableFood, row);
  }

  // ดึงรายการอาหารของ "วันนี้"
  Future<List<Map<String, dynamic>>> getTodayFoodList(String dateStr) async {
    Database db = await instance.database;
    return await db.query(tableFood, 
      where: "$columnDate LIKE ?", 
      whereArgs: ['$dateStr%'],
      orderBy: "$columnDate DESC"
    );
  }

  // คำนวณแคลอรี่รวมของ "วันนี้"
  Future<int> getTodayTotalCalories(String dateStr) async {
    Database db = await instance.database;
    var result = await db.rawQuery(
      "SELECT SUM($columnCalories) as total FROM $tableFood WHERE $columnDate LIKE ?", 
      ['$dateStr%']
    );
    
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as int);
    }
    return 0;
  }

  // 🔥 3. ดึงประวัติทั้งหมด (แก้จุดที่ Error)
  Future<List<Map<String, dynamic>>> getAllFoodHistory() async {
    final db = await instance.database;
    // ใช้ตัวแปร tableFood แทนการพิมพ์ 'food' สดๆ
    return await db.query(tableFood, orderBy: '$columnDate DESC'); 
  }
}