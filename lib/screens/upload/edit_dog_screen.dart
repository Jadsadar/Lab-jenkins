import 'package:flutter/material.dart';

import '../../data/mock_data.dart';

class EditDogScreen extends StatefulWidget {
  final Map<String, dynamic> dog;
  final Function(Map<String, dynamic>) onSave;

  const EditDogScreen({super.key, required this.dog, required this.onSave});

  @override
  State<EditDogScreen> createState() => _EditDogScreenState();
}

class _EditDogScreenState extends State<EditDogScreen> {
  late TextEditingController nameController;
  late TextEditingController breedController;
  late TextEditingController ageController;
  late TextEditingController weightController;
  late TextEditingController temperamentController;
  late TextEditingController storyController;
  late TextEditingController imageController;
  late TextEditingController reelController;

  late String selectedProvince;
  late String selectedGender;
  final List<String> genders = ['ผู้', 'เมีย'];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.dog['name']);
    breedController = TextEditingController(text: widget.dog['breed']);
    ageController = TextEditingController(text: widget.dog['age']);
    weightController = TextEditingController(text: widget.dog['weight']);
    temperamentController =
        TextEditingController(text: widget.dog['temperament']);
    storyController = TextEditingController(text: widget.dog['story']);
    imageController = TextEditingController(text: widget.dog['imageUrl']);
    reelController =
        TextEditingController(text: widget.dog['reelUrl'] ?? '');
    selectedProvince = thaiProvinces.contains(widget.dog['province'])
        ? widget.dog['province']
        : 'กรุงเทพมหานคร';
    selectedGender =
        genders.contains(widget.dog['gender']) ? widget.dog['gender'] : 'ผู้';
  }

  void saveChanges() {
    if (nameController.text.isNotEmpty && ageController.text.isNotEmpty) {
      final updatedDog = {
        "id": widget.dog['id'],
        "name": nameController.text,
        "breed":
            breedController.text.isEmpty ? "พันทาง" : breedController.text,
        "province": selectedProvince,
        "age": ageController.text,
        "gender": selectedGender,
        "weight": weightController.text.isEmpty ? "-" : weightController.text,
        "temperament": temperamentController.text.isEmpty
            ? "น่ารัก เป็นมิตร"
            : temperamentController.text,
        "story": storyController.text.isEmpty
            ? "ไม่มีข้อมูล"
            : storyController.text,
        "imageUrl": imageController.text.isNotEmpty
            ? imageController.text
            : "https://images.unsplash.com/photo-1543852786-1cf6624b9987?auto=format&fit=crop&w=400&q=60",
        "reelUrl": reelController.text,
        "status": widget.dog['status'],
        "engagementLikes": widget.dog['engagementLikes'] ?? 0,
      };
      widget.onSave(updatedDog);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อัปเดตข้อมูลสำเร็จ!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูล',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFFF9E68))),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFFFF9E68)),
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: 'ชื่อน้องหมา *',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)))),
            const SizedBox(height: 16),
            TextField(
                controller: breedController,
                decoration: InputDecoration(
                    labelText: 'สายพันธุ์',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)))),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: ageController,
                      decoration: InputDecoration(
                          labelText: 'อายุ *',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16))))),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: InputDecoration(
                      labelText: 'เพศ',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16))),
                  items: genders
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedGender = val!),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedProvince,
                  decoration: InputDecoration(
                      labelText: 'จังหวัด',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16))),
                  items: thaiProvinces
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => selectedProvince = val!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                  child: TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'น้ำหนัก (กก.)',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16))))),
            ]),
            const SizedBox(height: 16),
            TextField(
                controller: temperamentController,
                decoration: InputDecoration(
                    labelText: 'นิสัยเด่นๆ',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)))),
            const SizedBox(height: 16),
            TextField(
                controller: storyController,
                maxLines: 3,
                decoration: InputDecoration(
                    labelText: 'รายละเอียดเพิ่มเติม / เรื่องราวของน้อง',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)))),
            const SizedBox(height: 16),
            const Text('รูปภาพและวิดีโอ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87)),
            const SizedBox(height: 8),
            TextField(
                controller: imageController,
                decoration: InputDecoration(
                    labelText: 'URL รูปภาพโปรไฟล์น้องหมา',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    prefixIcon: const Icon(Icons.image))),
            const SizedBox(height: 16),
            TextField(
                controller: reelController,
                decoration: InputDecoration(
                    labelText: 'URL วิดีโอรีล (เว้นว่างได้ถ้าไม่มี)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    prefixIcon: const Icon(Icons.video_library))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('บันทึกการแก้ไข',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
