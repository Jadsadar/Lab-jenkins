import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/pet_avatar.dart';
import '../../widgets/pet_image_picker.dart';
import '../../widgets/province_picker.dart';
import '../detail/pet_detail_screen.dart';
import 'edit_dog_screen.dart';

class UploadScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddDog;
  final Function(Map<String, dynamic>) onDeleteDog;
  final Function(Map<String, dynamic>) onEditDog;
  final Function(Map<String, dynamic>, String) onChangeStatus;
  final List<Map<String, dynamic>> myPostedDogs;
  final List<Map<String, dynamic>> likedDogs;
  final Function(Map<String, dynamic>) onToggleFavorite;

  const UploadScreen({
    super.key,
    required this.onAddDog,
    required this.myPostedDogs,
    required this.onDeleteDog,
    required this.onChangeStatus,
    required this.onEditDog,
    required this.likedDogs,
    required this.onToggleFavorite,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController temperamentController = TextEditingController();
  final TextEditingController storyController = TextEditingController();

  String selectedProvince = 'กรุงเทพมหานคร';
  String selectedGender = 'ผู้';
  String? selectedAge;
  Uint8List? _pickedImageBytes;
  int _imagePickerResetKey = 0;
  bool _isSubmitting = false;
  final List<String> genders = ['ผู้', 'เมีย'];
  final List<String> ageOptions =
      List.generate(25, (index) => '${index + 1} ปี');

  Future<void> submitForm() async {
    if (nameController.text.isEmpty || selectedAge == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณากรอกชื่อและอายุ')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      String imageUrl = '';
      if (_pickedImageBytes != null) {
        imageUrl =
            await StorageService.instance.uploadPetImage(_pickedImageBytes!);
      }
      final currentUser = AuthService.instance.currentUser;
      final newDog = {
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "ownerId": currentUser?.uid,
        "ownerName": currentUser?.displayName ?? currentUserProfile['name'],
        "name": nameController.text,
        "breed":
            breedController.text.isEmpty ? "พันทาง" : breedController.text,
        "province": selectedProvince,
        "age": selectedAge!,
        "gender": selectedGender,
        "weight": weightController.text.isEmpty ? "-" : weightController.text,
        "temperament": temperamentController.text.isEmpty
            ? "น่ารัก เป็นมิตร"
            : temperamentController.text,
        "story": storyController.text.isEmpty
            ? "กำลังรอคนใจดีมารับไปดูแลอยู่ครับ/ค่ะ"
            : storyController.text,
        "imageUrl": imageUrl,
        "status": "ยังไม่ถูกรับเลี้ยง",
      };
      widget.onAddDog(newDog);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ประกาศหาบ้านสำเร็จ!')));
      nameController.clear();
      breedController.clear();
      weightController.clear();
      temperamentController.clear();
      storyController.clear();
      setState(() {
        selectedAge = null;
        _pickedImageBytes = null;
        _imagePickerResetKey++;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อัปโหลดรูปไม่สำเร็จ กรุณาลองใหม่อีกครั้ง')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'ถูกรับเลี้ยงแล้ว') return Colors.green.shade400;
    if (status == 'ยกเลิกประกาศ') return Colors.redAccent.shade200;
    return const Color(0xFFFF9E68);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ลงประกาศ',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFFF9E68))),
        backgroundColor: Colors.white,
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
                      borderRadius: BorderRadius.circular(16))),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: breedController,
              decoration: InputDecoration(
                  labelText: 'สายพันธุ์',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedAge,
                  decoration: InputDecoration(
                      labelText: 'อายุ *',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16))),
                  items: ageOptions
                      .map((age) =>
                          DropdownMenuItem(value: age, child: Text(age)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedAge = val),
                ),
              ),
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
                child: ProvinceField(
                  value: selectedProvince,
                  onChanged: (val) => setState(() => selectedProvince = val),
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
                            borderRadius: BorderRadius.circular(16)))),
              ),
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
            PetImagePicker(
              key: ValueKey(_imagePickerResetKey),
              onChanged: (bytes) =>
                  setState(() => _pickedImageBytes = bytes),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9E68),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 2,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('โพสต์หาบ้าน',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
            const Divider(color: Colors.black12),
            const SizedBox(height: 16),
            const Text('ประกาศของฉัน',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9E68))),
            const SizedBox(height: 12),
            widget.myPostedDogs.isEmpty
                ? const Text('คุณยังไม่ได้ลงประกาศสัตว์เลี้ยง',
                    style: TextStyle(color: Colors.grey))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.myPostedDogs.length,
                    itemBuilder: (context, index) {
                      final dog = widget.myPostedDogs[index];
                      final currentStatus =
                          dog['status'] ?? 'ยังไม่ถูกรับเลี้ยง';
                      return Card(
                        elevation: 0,
                        color: const Color(0xFFFFF6F0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color: Colors.orange.shade100, width: 1)),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PetDetailScreen(
                                        dog: dog,
                                        isMyPost: true,
                                        isFavorited: widget.likedDogs.any((d) => d['id'] == dog['id']),
                                        onToggleFavorite: () => widget.onToggleFavorite(dog),
                                      ))),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: PetAvatar(
                                    imageUrl: dog['imageUrl'],
                                    radius: 28,
                                  ),
                                  title: Text(dog['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFFFF9E68))),
                                  subtitle: Text(
                                      '${dog['province']} • อายุ ${dog['age']}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blueGrey),
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditDogScreen(
                                                        dog: dog,
                                                        onSave: widget
                                                            .onEditDog))),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent),
                                        onPressed: () {
                                          widget.onDeleteDog(dog);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'ลบประกาศเรียบร้อยแล้ว')));
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(color: Colors.white),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('สถานะปัจจุบัน:',
                                        style:
                                            TextStyle(color: Colors.black54)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(currentStatus)
                                            .withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: DropdownButton<String>(
                                        value: currentStatus,
                                        underline: const SizedBox(),
                                        icon: Icon(Icons.arrow_drop_down,
                                            color: _getStatusColor(
                                                currentStatus)),
                                        style: TextStyle(
                                          color:
                                              _getStatusColor(currentStatus),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                        ),
                                        items: [
                                          'ยังไม่ถูกรับเลี้ยง',
                                          'ถูกรับเลี้ยงแล้ว',
                                          'ยกเลิกประกาศ'
                                        ]
                                            .map((statusText) =>
                                                DropdownMenuItem(
                                                    value: statusText,
                                                    child: Text(statusText)))
                                            .toList(),
                                        onChanged: (newValue) {
                                          if (newValue != null) {
                                            widget.onChangeStatus(
                                                dog, newValue);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
