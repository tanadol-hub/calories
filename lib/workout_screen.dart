import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'database_helper.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  // Status ของ Player
  int _currentEnergy = 0;
  int _currentXp = 0;
  
  // ตัวแปรสำหรับ Animation
  bool _isWorkingOut = false;
  int _counter = 0;
  Timer? _timer;
  
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _loadStatus() async {
    String today = DateTime.now().toIso8601String().substring(0, 10);
    var status = await DatabaseHelper.instance.getTodayStatus(today);
    if (mounted) {
      setState(() {
        _currentEnergy = status['energy'] ?? 0;
        _currentXp = status['xp'] ?? 0;
      });
    }
  }

  // 🔊 ฟังก์ชันเล่นเสียงจากไฟล์ (Asset)
  Future<void> _playLocalSound() async {
    try {
      // ✅ แก้ชื่อไฟล์ตรงนี้ให้ตรงกับที่คุณมีใน assets/sounds/
      // เช่น 'sounds/lift.mp3', 'sounds/grunt.mp3'
      await _audioPlayer.play(AssetSource('sounds/lift.mp3')); 
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  // เริ่มต้นออกกำลังกาย (เช็ค Energy -> เริ่ม Animation)
  void _startExercise(String name, int burnCost, int xpGain) {
    // 1. เช็คพลังงาน
    if (_currentEnergy < burnCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("😵 หมดแรง! ไปกินข้าวก่อน (Not enough energy)"),
          backgroundColor: Colors.redAccent,
        )
      );
      return;
    }

    // 2. เริ่ม Animation Loop
    setState(() {
      _isWorkingOut = true;
      _counter = 0;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      setState(() {
        _counter++;
      });
      
      // เล่นเสียงทุกจังหวะยก!
      _playLocalSound();

      // เมื่อครบ 5 จังหวะ (3 วินาที) ให้จบ
      if (_counter >= 5) {
        timer.cancel();
        _finishExercise(name, burnCost, xpGain);
      }
    });
  }

  // จบการออกกำลังกาย -> บันทึก DB
  void _finishExercise(String name, int burnCost, int xpGain) async {
    await DatabaseHelper.instance.insertWorkout(name, burnCost, xpGain);
    
    // โหลดค่า Energy/XP ใหม่จาก DB
    _loadStatus(); 

    if (mounted) {
      setState(() {
        _isWorkingOut = false;
      });

      // Show Dialog Success
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text("SUCCESS! 🔥", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("ท่า: $name", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              Text("Burned: $burnCost kcal", style: TextStyle(color: Colors.redAccent)),
              Text("Gained: +$xpGain XP", style: TextStyle(color: Colors.yellowAccent)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("GYM & WORKOUT 💪", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: !_isWorkingOut, // ซ่อนปุ่ม back ตอนออกกำลังกาย
        actions: [
          Center(child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text("XP: $_currentXp", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.yellowAccent)),
          ))
        ],
      ),
      body: _isWorkingOut ? _buildAnimationView() : _buildSelectionView(),
    );
  }

  // 1. หน้าจอเลือกท่า (Grid View)
  Widget _buildSelectionView() {
    return Column(
      children: [
        // Energy Bar
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.black26,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("⚡ ENERGY:", style: TextStyle(color: Colors.white, fontSize: 18)),
              Text(
                "$_currentEnergy kcal", 
                style: TextStyle(
                  color: _currentEnergy > 100 ? Colors.greenAccent : Colors.red, 
                  fontSize: 24, fontWeight: FontWeight.bold
                )
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text("เลือกท่าออกกำลังกาย", style: TextStyle(color: Colors.grey)),
        
        // Grid Items
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(15),
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildWorkoutCard("Push Up", "วิดพื้น", 50, 10, Icons.accessibility_new),
              _buildWorkoutCard("Squat", "สควอช", 80, 20, Icons.directions_run),
              _buildWorkoutCard("Dumbbell", "ยกเวท", 120, 35, Icons.fitness_center),
              _buildWorkoutCard("Deadlift", "เดดลิฟท์", 200, 60, Icons.sports_gymnastics),
            ],
          ),
        ),
      ],
    );
  }

  // 2. หน้าจอตอนกำลังเล่น (Animation)
  Widget _buildAnimationView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _counter % 2 == 0 ? 200 : 230, // ยืดหด
            width: _counter % 2 == 0 ? 200 : 230,
            child: Image.asset('assets/images/body_fit.png'), // ใช้รูปที่มี
          ),
          const SizedBox(height: 30),
          const Text("PUMPING IRON! 🏋️‍♂️", style: TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              value: _counter / 5,
              minHeight: 10,
              backgroundColor: Colors.grey[800],
              color: Colors.greenAccent,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(String title, String subtitle, int cost, int xp, IconData icon) {
    bool canDo = _currentEnergy >= cost;
    return GestureDetector(
      onTap: () => _startExercise(title, cost, xp),
      child: Container(
        decoration: BoxDecoration(
          color: canDo ? const Color(0xFF1E1E1E) : Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: canDo ? Colors.greenAccent.withOpacity(0.5) : Colors.red.withOpacity(0.3)),
          boxShadow: canDo ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.1), blurRadius: 10)] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: canDo ? Colors.white : Colors.grey),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10)
              ),
              child: Text("⚡ -$cost | ⭐ +$xp", style: TextStyle(color: canDo ? Colors.yellow : Colors.grey, fontSize: 12)),
            )
          ],
        ),
      ),
    );
  }
}