import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'dashboard_screen.dart';

class UserSetupScreen extends StatefulWidget {
  const UserSetupScreen({super.key});

  @override
  State<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends State<UserSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  
  String _gender = 'male'; 

  // สีธีมสายฟิตเนส
  final Color _bgColor = const Color(0xFF1E1E1E); // ดำเทา
  final Color _cardColor = const Color(0xFF2C2C2C); // เทาอ่อนกว่านิดนึง
  final Color _accentColor = const Color(0xFF00E676); // เขียว Neon

  void _calculateAndStart() async {
    if (_formKey.currentState!.validate()) {
      double weight = double.parse(_weightController.text);
      double height = double.parse(_heightController.text);
      int age = int.parse(_ageController.text);

      double bmr;
      if (_gender == 'male') {
        bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
      } else {
        bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
      }
      double tdee = bmr * 1.35; 
      int target = tdee.round();

      await DatabaseHelper.instance.insertUser({
        'name': _nameController.text,
        'target_calories': target,
      });

      if (mounted) {
        // ใช้ SnackBar สีเข้ม
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Target: $target kcal/day 🔥 Let's Go!", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: _accentColor,
            behavior: SnackBarBehavior.floating,
          )
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    }
  }

  // ฟังก์ชันสร้าง Input สไตล์ Dark Mode
  Widget _buildInput(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: _accentColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }

  // ฟังก์ชันสร้างปุ่มเลือกเพศ
  Widget _buildGenderSelector(String value, String label, IconData icon) {
    bool isSelected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor : _cardColor,
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? null : Border.all(color: Colors.white10),
          boxShadow: isSelected 
            ? [BoxShadow(color: _accentColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))] 
            : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.black : Colors.grey, size: 30),
            const SizedBox(height: 5),
            Text(
              label, 
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey, 
                fontWeight: FontWeight.bold
              )
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              Text("SET UP YOUR", style: TextStyle(fontSize: 28, color: Colors.grey[400], fontWeight: FontWeight.w300)),
              Text("PROFILE 🔥", style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 10),
              Text("กรอกข้อมูลเพื่อคำนวณแคลอรี่ที่แม่นยำ", style: TextStyle(color: Colors.grey[600])),
              
              const SizedBox(height: 40),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInput(_nameController, "NICKNAME", Icons.person_outline),

                    // Gender Row
                    Row(
                      children: [
                        Expanded(child: _buildGenderSelector('male', 'MALE', Icons.male)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildGenderSelector('female', 'FEMALE', Icons.female)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Age & Weight Row
                    Row(
                      children: [
                        Expanded(child: _buildInput(_ageController, "AGE", Icons.cake, isNumber: true)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildInput(_weightController, "WEIGHT (kg)", Icons.monitor_weight_outlined, isNumber: true)),
                      ],
                    ),

                    _buildInput(_heightController, "HEIGHT (cm)", Icons.height, isNumber: true),

                    const SizedBox(height: 30),

                    // ปุ่ม Start ใหญ่ๆ
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _calculateAndStart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: Colors.black, // ตัวหนังสือสีดำ
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 10,
                          shadowColor: _accentColor.withOpacity(0.5),
                        ),
                        child: const Text(
                          "START JOURNEY 🚀", 
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}