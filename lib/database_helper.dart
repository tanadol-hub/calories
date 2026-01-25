import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // 🔥 1. เปลี่ยนชื่อ DB เป็นชื่อใหม่ (เพื่อรองรับระบบเกม RPG + XP)
  static const _databaseName = 'fitness_game_final.db';
  static const _databaseVersion = 1;

  // --- ตารางอาหาร (Food) ---
  static const tableFood = 'food';
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnCalories = 'calories';
  static const columnDate = 'date';
  // เพิ่มช่องเก็บ Macros เผื่อไว้ (โปรตีน/คาร์บ/ไขมัน)
  static const columnProtein = 'protein';
  static const columnCarbs = 'carbs';
  static const columnFat = 'fat';
  
  // 🔥 (เพิ่มใหม่) ใช้ตัวแปรเดียวกับ User ได้เลย หรือจะประกาศใหม่ก็ได้
  // แต่ในโค้ดคุณมี columnImage อยู่ด้านล่างแล้ว ผมเลยเอามาใช้ในตารางอาหารด้วยครับ

  // --- ตารางออกกำลังกาย (Workout) [ใหม่! 🏋️‍♂️] ---
  static const tableWorkout = 'workout';
  static const columnBurn = 'burned'; // แคลที่เบิร์น
  static const columnXpGain = 'xp';   // ค่าประสบการณ์กล้าม

  // --- ตารางผู้ใช้ (User) ---
  static const tableUser = 'user_data';
  static const columnTarget = 'target_calories';
  static const columnImage = 'image_path';
  // เพิ่มค่า Status ตัวละคร
  static const columnWeight = 'weight';
  static const columnMuscleXp = 'muscle_xp'; // 🔥 เก็บเลเวลกล้าม

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
    // 1. สร้างตารางอาหาร (เพิ่มช่องเก็บสารอาหารให้รองรับอนาคต)
    await db.execute('''
          CREATE TABLE $tableFood (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnName TEXT NOT NULL,
            $columnCalories INTEGER NOT NULL,
            $columnProtein INTEGER DEFAULT 0,
            $columnCarbs INTEGER DEFAULT 0,
            $columnFat INTEGER DEFAULT 0,
            $columnDate TEXT NOT NULL,
            $columnImage TEXT  -- 🔥 [เพิ่มตรงนี้] ให้ตารางอาหารเก็บ path รูปได้ครับ
          )
          ''');

    // 2. สร้างตารางผู้ใช้ (เพิ่ม XP และ น้ำหนัก)
    await db.execute('''
      CREATE TABLE $tableUser (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnTarget INTEGER NOT NULL,
        $columnWeight INTEGER DEFAULT 60,
        $columnMuscleXp INTEGER DEFAULT 0,
        $columnImage TEXT
      )
    ''');

    // 3. สร้างตารางออกกำลังกาย (ใหม่!)
    await db.execute('''
      CREATE TABLE $tableWorkout (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnBurn INTEGER NOT NULL,
        $columnXpGain INTEGER NOT NULL,
        $columnDate TEXT NOT NULL
      )
    ''');

    // สร้าง User เริ่มต้นให้เลย (กัน Error เวลาเปิดแอปครั้งแรก)
    await db.insert(tableUser, {
      columnName: 'Player 1',
      columnTarget: 2000,
      columnWeight: 70,
      columnMuscleXp: 0,
      columnImage: ''
    });
  }

  // ==========================================
  // ส่วนที่ 1: จัดการข้อมูลผู้ใช้ (User + XP)
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

  // ✅ ฟังก์ชันใหม่: ดึงค่าเฉลี่ยการกิน 30 วันย้อนหลัง (ใช้กำหนดรูปร่าง)
  Future<int> getAverageCaloriesLast30Days() async {
    final db = await instance.database;

    // หาวันที่ของ 30 วันที่แล้ว
    DateTime now = DateTime.now();
    DateTime thirtyDaysAgo = now.subtract(const Duration(days: 30));
    String startDate = thirtyDaysAgo.toIso8601String(); // แปลงเป็น String เพื่อเทียบใน DB

    // 1. หาผลรวมแคลอรี่ทั้งหมดในช่วง 30 วันที่ผ่านมา
    final resultTotal = await db.rawQuery(
        'SELECT SUM($columnCalories) as total FROM $tableFood WHERE $columnDate >= ?',
        [startDate]
    );

    // 2. หาจำนวนวันที่เรามีการจดบันทึกจริงๆ (นับเฉพาะวันที่กิน)
    final resultDays = await db.rawQuery(
        'SELECT COUNT(DISTINCT substr($columnDate, 1, 10)) as days FROM $tableFood WHERE $columnDate >= ?',
        [startDate]
    );

    int totalCalories = 0;
    int activeDays = 1; // เริ่มที่ 1 เพื่อป้องกันการหารด้วย 0

    if (resultTotal.isNotEmpty && resultTotal.first['total'] != null) {
      totalCalories = resultTotal.first['total'] as int;
    }

    if (resultDays.isNotEmpty && resultDays.first['days'] != null) {
      activeDays = resultDays.first['days'] as int;
    }

    if (activeDays == 0) activeDays = 1; // กันเหนียวอีกรอบ

    // คืนค่าเฉลี่ย (Total / Days)
    return (totalCalories / activeDays).round();
  }

  // ดึงประวัติอาหารทั้งหมด
  Future<List<Map<String, dynamic>>> getAllFoodHistory() async {
    final db = await instance.database;
    return await db.query(tableFood, orderBy: '$columnDate DESC');
  }

  // ==========================================
  // ส่วนที่ 3: จัดการออกกำลังกาย (Workout & Game Logic)
  // ==========================================

  // เพิ่มการออกกำลังกาย (และอัปเดต XP ผู้เล่นทันที)
  Future<void> insertWorkout(String name, int burn, int xp) async {
    Database db = await instance.database;

    // 1. บันทึกลง History การออกกำลังกาย
    await db.insert(tableWorkout, {
      columnName: name,
      columnBurn: burn,
      columnXpGain: xp,
      columnDate: DateTime.now().toIso8601String()
    });

    // 2. เพิ่ม XP ให้ตัวละคร (อัปเดต User)
    await db.rawUpdate('UPDATE $tableUser SET $columnMuscleXp = $columnMuscleXp + ? WHERE $columnId = 1', [xp]);
  }

  // 🔥 ฟังก์ชันเทพ: ดึงค่า Status ของวันนี้รวดเดียว (ใช้ในหน้า Dashboard)
  // คืนค่า: กินไปเท่าไหร่, เบิร์นไปเท่าไหร่, พลังงานคงเหลือ, XP ปัจจุบัน
  Future<Map<String, int>> getTodayStatus(String dateStr) async {
    Database db = await instance.database;

    // รวมแคลที่กินวันนี้
    var foodResult = await db.rawQuery(
        "SELECT SUM($columnCalories) as total FROM $tableFood WHERE $columnDate LIKE '$dateStr%'");
    int eaten = (foodResult.first['total'] as int?) ?? 0;

    // รวมแคลที่เบิร์นวันนี้ (Workout)
    var burnResult = await db.rawQuery(
        "SELECT SUM($columnBurn) as total FROM $tableWorkout WHERE $columnDate LIKE '$dateStr%'");
    int burned = (burnResult.first['total'] as int?) ?? 0;

    // ดึง XP ปัจจุบันของ User
    var userResult = await db.query(tableUser, limit: 1);
    int currentXp = 0;
    if (userResult.isNotEmpty) {
      currentXp = (userResult.first[columnMuscleXp] as int?) ?? 0;
    }

    return {
      'eaten': eaten,
      'burned': burned,
      'energy': eaten - burned, // 🔥 พลังงานคงเหลือ (ถ้าติดลบ คือหมดแรง)
      'xp': currentXp
    };
  }
}