import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart'; // อย่าลืม import เสียง
import 'database_helper.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _calController = TextEditingController(); // ช่องใส่แคลอรี่
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final AudioPlayer _audioPlayer = AudioPlayer(); // ตัวเล่นเสียง

  bool _isLoading = false;

  // 🎨 ธีมสี Dark Mode สุดเท่
  final Color _bgColor = const Color(0xFF1E1E1E);
  final Color _cardColor = const Color(0xFF2C2C2C);
  final Color _accentColor = const Color(0xFF00E676); // สีเขียวนีออน

  // 📖 ฐานข้อมูลอาหารส่วนตัว (Mock Database)
  // อยากเพิ่มเมนูไหน ใส่ตรงนี้ได้เลยครับ!
  // 📖 ฐานข้อมูลอาหารส่วนตัว (Mock Database) - ฉบับแก้บั๊กแล้ว
  final Map<String, int> _localMenu = {
    // ==========================================
    // 💪 โซนคนรักสุขภาพ & ฟิตเนส (Fitness & Clean)
    // ==========================================
    'อกไก่': 120, 'อกไก่ต้ม': 120, 'chicken breast': 120,
    'อกไก่ปั่น': 150, 'chicken smoothie': 150,
    'ไข่ต้ม': 80, 'boiled egg': 80,
    'ไข่ลวก': 80, 'soft boiled egg': 80,
    'ไข่ขาว': 17, 'egg white': 17,
    'ไข่ตุ๋น': 120, 'steamed egg': 120,
    'เวย์โปรตีน': 120, 'whey protein': 120,
    'โปรตีนเชค': 150, 'protein shake': 150,
    'สลัดอกไก่': 300, 'chicken salad': 300,
    'สลัดทูน่า': 250, 'tuna salad': 250,
    'สลัดผัก': 100, 'salad': 100,
    'ซีซาร์สลัด': 400, 'caesar salad': 400,
    'ข้าวไรซ์เบอร์รี่': 250, 'riceberry': 250,
    'ข้าวกล้อง': 110, 'brown rice': 110,
    'มันนึ่ง': 150, 'มันหวาน': 150, 'steamed potato': 150,
    'ฟักทองนึ่ง': 80, 'steamed pumpkin': 80,
    'ปลาแซลมอนย่าง': 400, 'grilled salmon': 400,
    'ปลาดอลลี่นึ่ง': 100, 'steamed dory': 100,
    'ปลากะพงนึ่งมะนาว': 250, 'steamed fish with lime': 250,
    'ทูน่ากระป๋อง': 150, 'canned tuna': 150, // ในน้ำแร่
    'กรีกโยเกิร์ต': 120, 'greek yogurt': 120,
    'โยเกิร์ต': 140, 'yogurt': 140,
    'กราโนล่า': 200, 'granola': 200,
    'ข้าวโอ๊ต': 150, 'oatmeal': 150,
    'อะโวคาโด': 160, 'avocado': 160,
    'อัลมอนด์': 160, 'almond': 160,
    'เนยถั่ว': 100, 'peanut butter': 100, // 1 ช้อนโต๊ะ
    'น้ำเปล่า': 0, 'water': 0,

    // ==========================================
    // 🍛 อาหารจานเดียว & กับข้าวไทย (Thai Street Food)
    // ==========================================
    'ข้าวมันไก่': 600, 'chicken rice': 600,
    'ข้าวมันไก่ทอด': 700, 'fried chicken rice': 700,
    'กะเพราหมูสับ': 550, 'กระเพรา': 550, 'basil pork': 550,
    'กะเพราไก่': 500, 'basil chicken': 500,
    'กะเพราเนื้อ': 600, 'basil beef': 600,
    'กะเพราไข่ดาว': 650, 'basil with egg': 650,
    'ข้าวไข่เจียว': 450, 'omelet rice': 450,
    'ข้าวไข่ข้น': 500, 'creamy omelet rice': 500,
    'ข้าวผัดหมู': 580, 'fried rice': 580,
    'ข้าวผัดกุ้ง': 550, 'shrimp fried rice': 550,
    'ข้าวผัดอเมริกัน': 700, 'american fried rice': 700,
    'ข้าวหมูทอดกระเทียม': 550, 'garlic pork rice': 550,
    'ข้าวขาหมู': 600, 'stewed pork leg': 600,
    'คากิ': 700,
    'ข้าวหมูแดง': 500, 'roasted pork rice': 500,
    'ข้าวหมูกรอบ': 600, 'crispy pork rice': 600,
    'ข้าวหน้าเป็ด': 500, 'roasted duck rice': 500,
    'ผัดไทย': 500, 'pad thai': 500,
    'ผัดไทยกุ้งสด': 550,
    'หอยทอด': 600, 'oyster omelet': 600,
    'ออส่วน': 550,
    'ส้มตำ': 120, 'papaya salad': 120,
    'ส้มตำปูปลาร้า': 100,
    'ไก่ย่าง': 250, 'grilled chicken': 250, // สะโพก
    'คอหมูย่าง': 350, 'grilled pork neck': 350,
    'ลาบหมู': 150, 'spicy pork salad': 150,
    'น้ำตกหมู': 160,
    'ต้มยำกุ้ง': 150, 'tom yum kung': 150, // น้ำใส
    'ต้มยำกุ้งน้ำข้น': 250,
    'แกงเขียวหวาน': 450, 'green curry': 450,
    'แกงส้ม': 150, 'sour curry': 150,
    'พะแนงหมู': 400, 'panang curry': 400,
    'ไข่พะโล้': 300, 'egg stew': 300,
    'หมูปิ้ง': 130, 'moo ping': 130,
    'ไก่ปิ้ง': 100,
    'ข้าวเหนียว': 100, 'sticky rice': 100,
    'ขนมจีนน้ำยา': 350,
    'ขนมจีนแกงเขียวหวาน': 450,

    // ==========================================
    // 🍜 ก๋วยเตี๋ยว & เส้น (Noodles)
    // ==========================================
    'ก๋วยเตี๋ยวหมู': 350, 'noodle': 350,
    'ก๋วยเตี๋ยวต้มยำ': 400, 'tom yum noodle': 400,
    'ก๋วยเตี๋ยวเรือ': 450, 'boat noodle': 450,
    'บะหมี่เกี๊ยว': 400, 'wonton noodle': 400,
    'บะหมี่แห้ง': 450, 'dry noodle': 450,
    'เย็นตาโฟ': 400, 'yentafo': 400,
    'ราดหน้า': 400, 'rad na': 400,
    'ผัดซีอิ๊ว': 600, 'pad see ew': 600,
    'ผัดมาม่า': 500, 'fried mama': 500,
    'มาม่าต้ม': 250, 'instant noodle': 250,
    'สุกี้แห้ง': 350, 'suki dry': 350,
    'สุกี้น้ำ': 300, 'suki soup': 300,
    'กวยจั๊บ': 450,
    'ยำวุ้นเส้น': 150, 'spicy glass noodle': 150,

    // ==========================================
    // 🌏 อาหารญี่ปุ่น & เกาหลี & อินเตอร์ (International)
    // ==========================================
    'ซูชิ': 50, 'sushi': 50,
    'ซาชิมิ': 100, 'sashimi': 100, // เซ็ตเล็ก
    'แซลมอนซาชิมิ': 200, 'salmon sashimi': 200,
    'ราเมน': 500, 'ramen': 500,
    'อุด้ง': 400, 'udon': 400,
    'ข้าวหน้าเนื้อ': 700, 'gyudon': 700,
    'ข้าวแกงกะหรี่': 700, 'curry rice': 700,
    'ทาโกยากิ': 300, 'takoyaki': 300,
    'กิมจิ': 30, 'kimchi': 30,
    'บิบิมบับ': 600, 'bibimbap': 600, 'ข้าวยำเกาหลี': 600,
    'ต๊อกบกกี': 400, 'tteokbokki': 400,
    'ไก่ทอดเกาหลี': 500, 'korean fried chicken': 500,
    'หมูกระทะ': 700, 'mookata': 700,
    'ชาบู': 600, 'shabu': 600,
    'สเต็กหมู': 500, 'pork steak': 500,
    'สเต็กเนื้อ': 600, 'beef steak': 600,
    'สเต็กไก่': 400, 'chicken steak': 400,
    'สเต็กปลา': 350, 'fish steak': 350,
    'พิซซ่า': 350, 'pizza': 350,
    'เบอร์เกอร์': 500, 'burger': 500,
    'ชีสเบอร์เกอร์': 600, 'cheeseburger': 600,
    'เฟรนช์ฟรายส์': 400, 'french fries': 400,
    'ไก่ทอด': 400, 'fried chicken': 400,
    'สปาเก็ตตี้': 500, 'spaghetti': 500,
    'คาโบนาร่า': 650, 'carbonara': 650,
    'ซุปเห็ด': 200, 'mushroom soup': 200,
    'แซนวิช': 250, 'sandwich': 250,
    'ฮอทดอก': 300, 'hotdog': 300,

    // ==========================================
    // ☕ เครื่องดื่ม & ของหวาน & ผลไม้ (Drinks & Desserts)
    // ==========================================
    'กาแฟดำ': 5, 'black coffee': 5, 'americano': 5,
    'ลาเต้': 200, 'latte': 200,
    'คาปูชิโน่': 200, 'cappuccino': 200,
    'เอสเพรสโซ่': 10, 'espresso': 10,
    'มอคค่า': 250, 'mocha': 250,
    'ชานมไข่มุก': 450, 'bubble tea': 450, 'boba': 450,
    'ชาเขียว': 250, 'green tea': 250, // ใส่นม
    'ชาไทย': 250, 'thai tea': 250,
    'โกโก้': 250, 'cocoa': 250,
    'นมสด': 150, 'milk': 150,
    'นมถั่วเหลือง': 100, 'soy milk': 100,
    'น้ำอัดลม': 140, 'soda': 140, 'coke': 140, 'pepsi': 140,
    'น้ำผลไม้': 120, 'juice': 120,
    'กล้วย': 100, 'กล้วยหอม': 100, 'banana': 100,
    'แอปเปิ้ล': 60, 'apple': 60,
    'ฝรั่ง': 60, 'guava': 60,
    'มะละกอ': 60, 'papaya': 60,
    'แตงโม': 50, 'watermelon': 50,
    'สับปะรด': 50, 'pineapple': 50,
    'ทุเรียน': 160, 'durian': 160,
    'มะม่วงสุก': 150, 'mango': 150,
    'มะม่วงดิบ': 100,
    'ขนมปัง': 80, 'bread': 80,
    'ขนมปังปิ้ง': 150, 'toast': 150,
    'เค้ก': 400, 'cake': 400,
    'ช็อคโกแลต': 150, 'chocolate': 150,
    'ไอศกรีม': 250, 'ice cream': 250,
    'บิงซู': 300, 'bingsu': 300,
    'โรตี': 300, 'roti': 300,
    'ปาท่องโก๋': 200,
    'ข้าวเหนียวมะม่วง': 450, 'mango sticky rice': 450,
    'บัวลอย': 300,
    'ลูกชิ้นทอด': 300, 'fried meatball': 300,
    'มันฝรั่งทอด': 150, 'chips': 150,
  };

  // ฟังก์ชันเลือกรูปจาก Gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // 🔍 ฟังก์ชันค้นหาแคลอรี่ (แบบไม่ง้อเน็ต)
  Future<void> _searchCalories() async {
    String query = _nameController.text.trim().toLowerCase(); // แปลงเป็นตัวเล็กให้หมดจะได้หาง่าย
    
    if (query.isEmpty) {
      _showSnackBar("พิมพ์ชื่อเมนูก่อนครับ", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus(); // เก็บแป้นพิมพ์

    // แกล้งๆ โหลดนิดนึงให้ดูเหมือนระบบกำลังประมวลผล (เท่ๆ) 🤣
    await Future.delayed(const Duration(milliseconds: 800));

    // ค้นหาในสมุดเมนูของเรา
    int? foundCalories;
    
    // 1. หาแบบตรงตัวเป๊ะๆ
    if (_localMenu.containsKey(query)) {
      foundCalories = _localMenu[query];
    } else {
      // 2. หาแบบมีคำคล้าย (เช่นพิมพ์ "ข้าว" ก็จะไปหา ข้าวผัด, ข้าวมันไก่)
      var entry = _localMenu.entries.firstWhere(
        (e) => e.key.contains(query),
        orElse: () => const MapEntry('', -1), // ถ้าไม่เจอให้คืนค่า -1
      );
      if (entry.value != -1) foundCalories = entry.value;
    }

    setState(() {
      if (foundCalories != null) {
        _calController.text = foundCalories.toString();
        _showSnackBar("เจอแล้ว! $query = $foundCalories kcal 🔥", _accentColor);
      } else {
        _calController.text = "";
        _showSnackBar("ไม่พบเมนูนี้ กรอกแคลอรี่เองได้เลยครับ ✍️", Colors.redAccent);
      }
      _isLoading = false;
    });
  }

  // 💾 ฟังก์ชันบันทึกข้อมูล
  void _saveFood() async {
    if (_nameController.text.isEmpty) {
      _showSnackBar("กรุณาใส่ชื่อเมนู", Colors.red);
      return;
    }
    
    // แปลงค่าแคลอรี่จากช่องกรอก
    int calories = int.tryParse(_calController.text) ?? 0;
    if (calories == 0) {
       _showSnackBar("กรุณาระบุแคลอรี่ หรือกดค้นหาแว่นขยาย", Colors.orange);
       return;
    }

    // 🔊 เล่นเสียงกิน (eat.mp3)
    try {
      await _audioPlayer.play(AssetSource('sounds/eat.mp3')); 
    } catch (e) {
      print("Error playing sound: $e"); // เผื่อไฟล์เสียงไม่มี จะได้ไม่แอปเด้ง
    }

    // เตรียมข้อมูล
    final imagePath = _selectedImage?.path ?? '';
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: _nameController.text,
      DatabaseHelper.columnCalories: calories,
      DatabaseHelper.columnDate: DateTime.now().toIso8601String(),
      'image_path': imagePath,
    };

    // บันทึกลง Database
    await DatabaseHelper.instance.insertFood(row);

    // ปิดหน้า
    if (mounted) {
      Navigator.pop(context, true); 
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), 
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text("ADD MEAL (OFFLINE) 🍽️", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: _bgColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. ส่วนเลือกรูปภาพ (ดีไซน์ Dark Mode)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[800]!),
                    image: _selectedImage != null
                        ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 50, color: Colors.grey[600]),
                            const SizedBox(height: 10),
                            Text("แตะเพื่อเพิ่มรูปอาหาร", style: TextStyle(color: Colors.grey[500])),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 25),

              // 2. ช่องค้นหาชื่อเมนู
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "ชื่อเมนู (Menu Name)",
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        hintText: "เช่น กะเพรา, Pizza...",
                        hintStyle: TextStyle(color: Colors.grey[700]),
                        filled: true,
                        fillColor: _cardColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.fastfood, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // ปุ่มค้นหา
                  Container(
                    decoration: BoxDecoration(
                      color: _accentColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      onPressed: _isLoading ? null : _searchCalories,
                      icon: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) 
                        : const Icon(Icons.search, color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. ส่วนกรอกแคลอรี่ (ให้แก้ได้เผื่อไม่ตรงใจ)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _accentColor.withOpacity(0.5), width: 1),
                ),
                child: Column(
                  children: [
                    const Text("CALORIES / KCAL", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 2)),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _calController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: _accentColor, fontSize: 40, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "0",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const Text("กดแว่นขยาย หรือ กรอกเองก็ได้", style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),

              // 4. ปุ่มบันทึก
              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _saveFood,
                  icon: const Icon(Icons.check_circle, color: Colors.black),
                  label: const Text("บันทึกความอร่อย! (SAVE)", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor, // สีเขียว Neon
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    shadowColor: _accentColor.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}