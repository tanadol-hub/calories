import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // เพิ่ม import
import 'dart:io';
import 'database_helper.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentTarget;
  final String? currentImage; // รับรูปเดิมมาด้วย

  const EditProfileScreen({
    super.key, 
    required this.currentName, 
    required this.currentTarget,
    this.currentImage
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetController;
  File? _selectedImage; // ตัวแปรเก็บรูปใหม่ที่เลือก

  final Color _bgColor = const Color(0xFF1E1E1E);
  final Color _accentColor = const Color(0xFF00E676);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _targetController = TextEditingController(text: widget.currentTarget);
    // ถ้ามีรูปเดิม ให้โหลดมาโชว์ก่อน
    if (widget.currentImage != null && widget.currentImage!.isNotEmpty) {
      _selectedImage = File(widget.currentImage!);
    }
  }

  // ฟังก์ชันเลือกรูป
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> row = {
        '_id': 1,
        'name': _nameController.text,
        'target_calories': int.parse(_targetController.text),
        'image_path': _selectedImage?.path ?? '', // บันทึก Path รูป
      };

      await DatabaseHelper.instance.updateUser(row);

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text("EDIT PROFILE ⚙️", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _bgColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView( // เผื่อคีย์บอร์ดบัง
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ส่วนเลือกรูป (กดได้แล้ว!)
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                          border: Border.all(color: _accentColor, width: 3),
                          image: _selectedImage != null && _selectedImage!.existsSync()
                              ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _selectedImage == null
                            ? const Icon(Icons.person, size: 70, color: Colors.white)
                            : null,
                      ),
                      // ไอคอนกล้องเล็กๆ มุมขวาล่าง
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // ช่องแก้ชื่อ
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'ชื่อเล่น',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.edit, color: _accentColor),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!), borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _accentColor), borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[900],
                  ),
                  validator: (val) => val!.isEmpty ? 'กรุณาใส่ชื่อ' : null,
                ),
                const SizedBox(height: 20),

                // ช่องแก้เป้าหมาย
                TextFormField(
                  controller: _targetController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'เป้าหมายแคลอรี่ต่อวัน',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.flag, color: _accentColor),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!), borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _accentColor), borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[900],
                  ),
                  validator: (val) => val!.isEmpty ? 'กรุณาใส่ตัวเลข' : null,
                ),
                const SizedBox(height: 40),

                // ปุ่มบันทึก
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("บันทึกการเปลี่ยนแปลง", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}