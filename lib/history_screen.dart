import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ใช้จัดรูปแบบวันที่
import 'dart:io';
import 'database_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Map<String, List<Map<String, dynamic>>> _groupedHistory = {};
  bool _isLoading = true;

  // ธีมสี (ใช้ชุดเดียวกับหน้าแรก)
  final Color _bgColor = const Color(0xFF1E1E1E);
  final Color _cardColor = const Color(0xFF2C2C2C);
  final Color _accentColor = const Color(0xFF00E676);

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    final allFood = await DatabaseHelper.instance.getAllFoodHistory();
    
    // จัดกลุ่มข้อมูลตามวันที่ (Group by Date)
    Map<String, List<Map<String, dynamic>>> grouped = {};
    
    for (var food in allFood) {
      // แปลงวันที่เป็น String สั้นๆ เช่น "2023-10-25"
      String dateKey = food['date'].toString().split('T')[0];
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(food);
    }

    setState(() {
      _groupedHistory = grouped;
      _isLoading = false;
    });
  }

  // คำนวณแคลอรี่รวมของวันนั้นๆ
  int _calculateDailyTotal(List<Map<String, dynamic>> foods) {
    int total = 0;
    for (var f in foods) {
      total += (f['calories'] as int);
    }
    return total;
  }

  // แปลงวันที่เป็นคำพูด (เช่น วันนี้, เมื่อวาน)
  String _formatDateTitle(String dateKey) {
    DateTime date = DateTime.parse(dateKey);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return "Today (วันนี้) 🔥";
    if (checkDate == yesterday) return "Yesterday (เมื่อวาน) ⏮️";
    return DateFormat('dd MMM yyyy').format(date); // เช่น 18 Jan 2026
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text("HISTORY LOG 📅", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: _bgColor,
        foregroundColor: Colors.white, // สีปุ่ม back
        elevation: 0,
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: _accentColor))
        : _groupedHistory.isEmpty
          ? Center(child: Text("ยังไม่มีประวัติการกิน", style: TextStyle(color: Colors.grey[600])))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _groupedHistory.keys.length,
              itemBuilder: (context, index) {
                String dateKey = _groupedHistory.keys.elementAt(index);
                List<Map<String, dynamic>> dailyFoods = _groupedHistory[dateKey]!;
                int dailyTotal = _calculateDailyTotal(dailyFoods);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // หัวข้อวันที่
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDateTitle(dateKey),
                            style: TextStyle(color: _accentColor, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Total: $dailyTotal kcal",
                            style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    // การ์ดรายการอาหาร
                    ...dailyFoods.map((food) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                              image: (food['imagePath'] != null && food['imagePath'] != '' && File(food['imagePath']).existsSync())
                                ? DecorationImage(image: FileImage(File(food['imagePath'])), fit: BoxFit.cover)
                                : null,
                            ),
                            child: (food['imagePath'] == null || food['imagePath'] == '') 
                              ? Icon(Icons.fastfood, color: Colors.grey[700], size: 20) : null,
                          ),
                          title: Text(food['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            DateFormat('HH:mm').format(DateTime.parse(food['date'])), // เวลาที่กิน
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                          trailing: Text(
                            "${food['calories']}",
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 15), // ระยะห่างระหว่างวัน
                    Divider(color: Colors.grey[800]), // เส้นคั่นวัน
                  ],
                );
              },
            ),
    );
  }
}