import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'workout_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // รายชื่อหน้าที่จะสลับ
  final List<Widget> _screens = [
    const DashboardScreen(), // หน้า 0: ดูหุ่น & กินข้าว
    const WorkoutScreen(),   // หน้า 1: ออกกำลังกาย
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // โชว์หน้าตามที่เลือก
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: const Color(0xFF00E676), // สีเขียวเมื่อเลือก
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'MY BODY',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'WORKOUT',
          ),
        ],
      ),
    );
  }
}