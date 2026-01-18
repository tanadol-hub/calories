import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'user_setup_screen.dart';
import 'dashboard_screen.dart'; // <--- เพิ่มบรรทัดนี้

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tamagotchi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // ในความเป็นจริงเราต้องเช็คก่อนว่ามี User หรือยัง แต่ตอนนี้ให้เปิดหน้า Setup ก่อนเลย
      home: const CheckUserWrapper(),
    );
  }
}

// ตัวเช็คว่าควรไปหน้าไหน (Setup หรือ Home)
class CheckUserWrapper extends StatefulWidget {
  const CheckUserWrapper({super.key});

  @override
  _CheckUserWrapperState createState() => _CheckUserWrapperState();
}

class _CheckUserWrapperState extends State<CheckUserWrapper> {
  bool? hasUser;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  void _checkUser() async {
    final user = await DatabaseHelper.instance.getUser();
    setState(() {
      hasUser = user != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (hasUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator())); // กำลังโหลด
    }
    if (hasUser == true) {
      return DashboardScreen(); // มี User แล้วไปหน้าหลัก
    } else {
      return const UserSetupScreen(); // ยังไม่มี User ไปหน้าสร้าง
    }
  }
}

// --- หน้า Home ชั่วคราว (Placeholder) ---
// เราจะมาแก้หน้านี้ในขั้นตอนถัดไป ให้เป็น Dashboard จริงๆ
// แก้ไขเฉพาะ class นี้ในไฟล์ lib/main.dart

class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("หน้าหลัก (รอพัฒนา)"),
        actions: [
          // ปุ่ม Reset อยู่มุมขวาบน
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.red),
            onPressed: () async {
              // 1. ลบข้อมูล User ใน Database
              final db = await DatabaseHelper.instance.database;
              await db.delete('user_profile');
              
              // 2. รีสตาร์ทแอปกลับไปหน้าแรก
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const CheckUserWrapper()),
                  (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text("บันทึกข้อมูลเรียบร้อย!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("ระบบจำค่าของคุณไว้แล้ว"),
            const SizedBox(height: 10),
            const Text("(กดปุ่มสีแดงมุมขวาบน เพื่อลบค่าแล้วเริ่มใหม่)", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                 // เดี๋ยวเราจะทำปุ่มนี้ให้ไปหน้า Dashboard ของจริง
              },
              child: const Text("รอทำหน้า Dashboard ต่อไป..."),
            )
          ],
        ),
      ),
    );
  }
}