import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // ชื่อไฟล์ฐานข้อมูล
  static const _databaseName = 'calories.db'; // <--- ตัวนี้แหละครับที่ Error เมื่อกี้
  static const _databaseVersion = 1;

  // --- ตารางอาหาร (สำหรับหน้า AddFood & Dashboard) ---
  static const tableFood = 'food_data';
  static const columnCalories = 'calories';
  static const columnDate = 'date';

  // --- ตารางผู้ใช้ (สำหรับหน้า UserSetup & Dashboard) ---
  static const tableUser = 'user_data';
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnTarget = 'target_calories';
  static const columnImage = 'image_path';

  // ทำให้เป็น Singleton
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
    await db.execute('''
          CREATE TABLE $tableFood (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnCalories INTEGER NOT NULL,
            $columnImage TEXT NOT NULL,
            $columnDate TEXT NOT NULL
          )
          ''');
    
    // 2. สร้างตารางผู้ใช้
    await db.execute('''
      CREATE TABLE $tableUser (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnTarget INTEGER NOT NULL,
        $columnImage TEXT  -- ช่องนี้สำคัญ!
      )
    ''');
  }

  // ==========================================
  // ส่วนที่ 1: จัดการข้อมูลผู้ใช้ (User)
  // ==========================================
  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    await db.delete(tableUser); // ลบข้อมูลเก่าก่อน (เพราะเรามี User คนเดียว)
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

  // ==========================================
  // ส่วนที่ 2: จัดการข้อมูลอาหาร (Food)
  // ==========================================
  
  // เพิ่มอาหาร (ใช้ในหน้า AddFood)
  Future<int> addFood(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableFood, row);
  }

  // ดึงรายการอาหารของ "วันนี้" (ใช้ในหน้า Dashboard)
  Future<List<Map<String, dynamic>>> getTodayFoodList(String dateStr) async {
    Database db = await instance.database;
    // ค้นหาโดยดูว่าวันที่ "ขึ้นต้นด้วย" วันที่ที่ส่งมาหรือไม่ (เช่น '2026-01-18%')
    return await db.query(tableFood, 
      where: "$columnDate LIKE ?", 
      whereArgs: ['$dateStr%'],
      orderBy: "$columnDate DESC"
    );
  }

  // คำนวณแคลอรี่รวมของ "วันนี้" (ใช้ในหน้า Dashboard)
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
  // ... (โค้ดเก่า) ...

  // ดึงข้อมูลอาหารทั้งหมด เรียงจากล่าสุดไปเก่าสุด
  Future<List<Map<String, dynamic>>> getAllFoodHistory() async {
    final db = await instance.database;
    return await db.query('food', orderBy: 'date DESC');
  }
  // ... (โค้ดเก่า) ...

  // อัปเดตข้อมูลผู้ใช้ (แก้ไขชื่อ หรือ เป้าหมายแคล)
  Future<int> updateUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    // อัปเดตแถวแรกสุด (เพราะเรามี User คนเดียว)
    return await db.update(tableUser, row, where: '$columnId = ?', whereArgs: [1]);
  }
  Future<int> insertFood(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableFood, row);
  }
} // จบ Class
 // จบ Class
  
