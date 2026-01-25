import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'user_setup_screen.dart';
import 'main_screen.dart'; // <--- สำคัญ! เราต้องเรียกตัวนี้เพื่อให้มีเมนูด้านล่าง

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness RPG', // ตั้งชื่อแอปให้เท่ๆ
      debugShowCheckedModeBanner: false, // เอาแถบ Debug มุมขวาบนออก

      // 🔥 ตั้งค่า Theme รวม (Dark Mode) ให้เข้ากับหน้า Dashboard
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00E676), // สีเขียวนีออน
        scaffoldBackgroundColor: const Color(0xFF1E1E1E), // สีพื้นหลังหลัก
        useMaterial3: true,
        // กำหนดสีพื้นฐานให้ทั้งแอป
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFF00E676),
          surface: Color(0xFF2C2C2C),
        ),
      ),

      // เริ่มต้นที่ตัวเช็ค User
      home: const CheckUserWrapper(),
    );
  }
}

// ---------------------------------------------------------
// ตัวเช็คว่าควรไปหน้าไหน (Setup หรือ Main Game)
// ---------------------------------------------------------
class CheckUserWrapper extends StatefulWidget {
  const CheckUserWrapper({super.key});

  @override
  State<CheckUserWrapper> createState() => _CheckUserWrapperState();
}

class _CheckUserWrapperState extends State<CheckUserWrapper> {
  bool? hasUser;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  // ฟังก์ชันเช็คว่ามี User ใน Database หรือยัง
  void _checkUser() async {
    final user = await DatabaseHelper.instance.getUser();
    if (mounted) {
      setState(() {
        hasUser = user != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. สถานะกำลังโหลด (หมุนติ้วๆ สีเขียว)
    if (hasUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E676)),
        ),
      );
    }
    
    // 2. ถ้ามี User แล้ว -> ไปหน้า MainScreen (หน้าที่มี Tab Bar Dashboard/Gym/History)
    if (hasUser == true) {
      return const MainScreen(); 
    } 
    
    // 3. ถ้ายังไม่มี User -> ไปหน้าตั้งค่า UserSetupScreen
    else {
      return const UserSetupScreen(); 
    }
  }
}