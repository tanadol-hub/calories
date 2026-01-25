import 'dart:io'; // ✅ 1. เพิ่มบรรทัดนี้เพื่อจัดการไฟล์รูปภาพ
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'add_food_screen.dart';
import 'history_screen.dart';
import 'edit_profile_screen.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = "Player 1";
  double targetCalories = 2000;
  
  // 🔥 ตัวแปรสำหรับระบบเกม
  int _eatenCalories = 0;
  int _burnedCalories = 0;
  int _netEnergy = 0; 
  int _muscleXp = 0;  
  int _averageCalories = 0; 

  List<Map<String, dynamic>> todayFoodList = [];
  String? userImage; 

  // ธีมสี (Dark Mode)
  final Color _bgColor = const Color(0xFF121212);
  final Color _cardColor = const Color(0xFF1E1E1E);
  final Color _accentColor = const Color(0xFF00E676);
  final Color _textWhite = Colors.white;
  final Color _textGrey = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    String today = DateTime.now().toIso8601String().substring(0, 10);
    
    final status = await DatabaseHelper.instance.getTodayStatus(today);
    final avgCal = await DatabaseHelper.instance.getAverageCaloriesLast30Days();
    final user = await DatabaseHelper.instance.getUser();
    final foodList = await DatabaseHelper.instance.getTodayFoodList(today);

    if (mounted) {
      setState(() {
        if (user != null) {
          userName = user['name'] ?? "Player 1";
          targetCalories = (user['target_calories'] as int?)?.toDouble() ?? 2000.0;
          userImage = user['image_path'];
        }
        
        _eatenCalories = status['eaten'] ?? 0;
        _burnedCalories = status['burned'] ?? 0;
        _netEnergy = status['energy'] ?? 0;
        _muscleXp = status['xp'] ?? 0;
        
        _averageCalories = avgCal;
        
        if (_averageCalories == 0 && _eatenCalories > 0) {
          _averageCalories = _eatenCalories;
        }

        todayFoodList = foodList;
      });
    }
  }

  // 🦍 Logic สร้างอวตาร
  Widget _buildAvatar() {
    String statusText = "NORMAL";
    Color statusColor = Colors.white;
    String imageAsset = 'assets/images/body_fit.png'; 

    if (_averageCalories > (targetCalories + 500)) {
      statusText = "FAT (เริ่มอ้วน)";
      statusColor = Colors.redAccent;
      imageAsset = 'assets/images/body_fat.png';
    } 
    else if (_averageCalories < (targetCalories - 500) && _averageCalories > 0) {
      statusText = "SKINNY (ผอมแห้ง)";
      statusColor = Colors.orangeAccent;
      imageAsset = 'assets/images/body_skinny.png';
    } 
    else {
      if (_muscleXp > 1000) {
        statusText = "TITAN (ร่างเทพ)";
        statusColor = Colors.amberAccent;
        imageAsset = 'assets/images/body_hulk.png';
      } else if (_muscleXp > 300) {
        statusText = "ATHLETE (หุ่นดี)";
        statusColor = Colors.greenAccent;
        imageAsset = 'assets/images/body_fit.png';
      } else {
        statusText = "NORMAL (สมส่วน)";
        statusColor = Colors.white;
        imageAsset = 'assets/images/body_fit.png';
      }
    }

    return Column(
      children: [
        Container(
          height: 220, 
          width: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor.withOpacity(0.1),
            boxShadow: [
              BoxShadow(color: statusColor.withOpacity(0.3), blurRadius: 40, spreadRadius: 5)
            ]
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset(
              imageAsset,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.accessibility_new, size: 100, color: statusColor);
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          statusText, 
          style: TextStyle(
            color: statusColor, 
            fontSize: 28, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 1.5,
            shadows: [Shadow(color: statusColor, blurRadius: 10)]
          )
        ),
        Text("Muscle XP: $_muscleXp / 1000", style: TextStyle(color: _textGrey, fontSize: 14)),
        
        const SizedBox(height: 5),
        Text(
          "30-Day Avg Intake: $_averageCalories kcal", 
          style: TextStyle(color: Colors.white24, fontSize: 10)
        ),
      ],
    );
  }

  // ✅ 2. ฟังก์ชันแสดงรูปอาหาร (ถ้ามีรูปให้โชว์รูป ถ้าไม่มีให้โชว์ไอคอน)
  Widget _buildFoodImage(String? imagePath) {
    if (imagePath != null && imagePath.isNotEmpty) {
      File imgFile = File(imagePath);
      if (imgFile.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            imgFile,
            width: 50,
            height: 50,
            fit: BoxFit.cover, // ตัดภาพให้เต็มกรอบสี่เหลี่ยมสวยๆ
          ),
        );
      }
    }
    // ถ้าไม่มีรูป หรือหาไฟล์ไม่เจอ ให้ใช้ไอคอนเดิม
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.fastfood, color: Colors.white, size: 24),
    );
  }

  void _editProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentName: userName,
          currentTarget: targetCalories.toInt().toString(),
          currentImage: userImage,
        ),
      ),
    );
    _loadData(); 
  }

  void _navigateToAddFood() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddFoodScreen()),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    double progressValue = (targetCalories > 0) ? _eatenCalories / targetCalories : 0;
    if (progressValue > 1) progressValue = 1;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text("MY EVOLUTION 🧬", style: TextStyle(fontWeight: FontWeight.w900, color: _textWhite, letterSpacing: 1.5)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
            IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(),
              
              const SizedBox(height: 30),

              // Stats Dashboard
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem("EATEN", "$_eatenCalories", Colors.white),
                        Container(height: 40, width: 1, color: Colors.white24),
                        _buildStatItem("BURNED", "$_burnedCalories", Colors.redAccent),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("ENERGY BALANCE", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            "$_netEnergy kcal", 
                            style: TextStyle(
                              color: _netEnergy >= 0 ? _accentColor : Colors.red,
                              fontSize: 18, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 10,
                        backgroundColor: Colors.black,
                        color: _accentColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text("Goal: ${targetCalories.toInt()}", style: TextStyle(color: _textGrey, fontSize: 10)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _navigateToAddFood,
                  icon: const Icon(Icons.add, color: Colors.black, size: 28),
                  label: const Text("EAT FOOD", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerLeft,
                child: Text("TODAY'S FUEL", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textWhite)),
              ),
              const SizedBox(height: 15),
              
              todayFoodList.isEmpty 
              ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text("ยังไม่ได้เติมพลังเลย... หิวไหม?", style: TextStyle(color: Colors.grey[700])),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todayFoodList.length,
                  itemBuilder: (context, index) {
                    final food = todayFoodList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        // ✅ 3. เรียกใช้ฟังก์ชันแสดงรูปตรงนี้
                        leading: _buildFoodImage(food['image_path']), 
                        
                        title: Text(food['name'], style: TextStyle(color: _textWhite, fontWeight: FontWeight.bold)),
                        subtitle: Text("Pro: ${food['protein'] ?? 0}g", style: TextStyle(color: _textGrey, fontSize: 12)),
                        trailing: Text("+${food['calories']}", style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: _textGrey, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(color: valueColor, fontSize: 24, fontWeight: FontWeight.w900)),
      ],
    );
  }
}