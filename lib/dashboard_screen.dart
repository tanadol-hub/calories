import 'package:flutter/material.dart';
import 'dart:io';
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
  String userName = "User";
  double targetCalories = 2000;
  double currentCalories = 0;
  String? userImage;
  List<Map<String, dynamic>> todayFoodList = [];
  String avatarStatus = 'normal';

  // ธีมสี (Dark Mode)
  final Color _bgColor = const Color(0xFF1E1E1E);
  final Color _cardColor = const Color(0xFF2C2C2C);
  final Color _accentColor = const Color(0xFF00E676);
  final Color _textWhite = Colors.white;
  final Color _textGrey = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final user = await DatabaseHelper.instance.getUser();
    String today = DateTime.now().toString().split(' ')[0];
    
    // ดึงแคลอรี่รวม
    final int totalCalInt = await DatabaseHelper.instance.getTodayTotalCalories(today);
    // ดึงรายการอาหาร
    final foodList = await DatabaseHelper.instance.getTodayFoodList(today);

    if (mounted) {
      setState(() {
        if (user != null) {
          userName = user['name'] ?? "User";
          targetCalories = (user['target_calories'] as num).toDouble();
          userImage = user['image_path'];
        }
        currentCalories = totalCalInt.toDouble();
        todayFoodList = foodList;

        double progress = (targetCalories > 0) ? currentCalories / targetCalories : 0;
        if (progress < 0.2) avatarStatus = 'hungry';
        else if (progress >= 1.0) avatarStatus = 'full';
        else avatarStatus = 'normal';
      });
    }
  }

  // ฟังก์ชันไปหน้าแก้ไขโปรไฟล์
  void _editProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentName: userName,
          currentTarget: targetCalories.toInt().toString(),
          currentImage: userImage,
        ),
      ),
    );
    if (result == true) _loadData(); 
  }

  void _navigateToAddFood() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddFoodScreen()),
    );
    if (result == true) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    double progressValue = (targetCalories > 0) ? currentCalories / targetCalories : 0;
    if (progressValue > 1) progressValue = 1;
    int remaining = (targetCalories - currentCalories).toInt();
    if (remaining < 0) remaining = 0;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text("DASHBOARD ⚡", style: TextStyle(fontWeight: FontWeight.w900, color: _textWhite, letterSpacing: 1.5)),
        centerTitle: true,
        backgroundColor: _bgColor,
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
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. การ์ด Main Stats
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  children: [
                    // ส่วน Profile Header
                    Row(
                      children: [
                        Container(
                          width: 70, height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[800],
                            border: Border.all(color: _accentColor, width: 2),
                            image: (userImage != null && userImage!.isNotEmpty && File(userImage!).existsSync())
                                ? DecorationImage(image: FileImage(File(userImage!)), fit: BoxFit.cover)
                                : null,
                          ),
                          child: (userImage == null || userImage!.isEmpty) 
                                ? Icon(Icons.person, size: 40, color: Colors.grey[400]) 
                                : null, 
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName, 
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textWhite),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Keep Burning! 🔥",
                                style: TextStyle(color: _accentColor, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),

                    // ตัวเลขแคลอรี่
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("EATEN", style: TextStyle(color: _textGrey, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text("${currentCalories.toInt()}", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: _textWhite)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("GOAL", style: TextStyle(color: _textGrey, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text("${targetCalories.toInt()}", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: _accentColor)),
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 15),
                    
                    // Progress Bar
                    Stack(
                      children: [
                        Container(
                          height: 12,
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                        ),
                        FractionallySizedBox(
                          widthFactor: progressValue,
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: _accentColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: _accentColor.withOpacity(0.6), blurRadius: 10)]
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text("อีก $remaining kcal จะถึงเป้าหมาย", style: TextStyle(color: _textGrey, fontSize: 12)),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 2. ปุ่มกดบันทึก
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: _navigateToAddFood,
                  icon: const Icon(Icons.add_circle_outline, color: Colors.black, size: 28),
                  label: const Text("RECORD MEAL 🍽️", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    shadowColor: _accentColor.withOpacity(0.4),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 3. รายการอาหาร
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("TODAY'S LOG", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _textWhite, letterSpacing: 1)),
                  Text("${todayFoodList.length} items", style: TextStyle(color: _textGrey)),
                ],
              ),
              const SizedBox(height: 15),
              
              todayFoodList.isEmpty 
              ? Center(child: Text("ยังไม่ได้กินอะไรเลยหรอ? 🤔", style: TextStyle(color: Colors.grey[600])))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todayFoodList.length,
                  itemBuilder: (context, index) {
                    final food = todayFoodList[index];
                    
                    // --- แก้จุดนี้ครับ: เปลี่ยน imagePath เป็น image_path ---
                    // เพราะใน Database เราใช้ชื่อ column ว่า image_path (มี underscore)
                    String? imagePath = food['image_path']; 
                    
                    bool hasImage = imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        leading: Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                            // โชว์รูปตรงนี้
                            image: hasImage ? DecorationImage(image: FileImage(File(imagePath)), fit: BoxFit.cover) : null,
                          ),
                          // ถ้าไม่มีรูป ให้โชว์ไอคอน
                          child: !hasImage ? Icon(Icons.fastfood, color: Colors.grey[800]) : null,
                        ),
                        title: Text(food['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textWhite)),
                        subtitle: Text(
                          // ตัดเวลาให้เหลือแค่ HH:mm
                          food['date'].toString().split('T').length > 1 
                            ? food['date'].toString().split('T')[1].substring(0, 5) 
                            : "",
                          style: TextStyle(color: _textGrey)
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _accentColor.withOpacity(0.3))
                          ),
                          child: Text("${food['calories']} kcal", style: TextStyle(fontSize: 14, color: _accentColor, fontWeight: FontWeight.bold)),
                        ),
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
}