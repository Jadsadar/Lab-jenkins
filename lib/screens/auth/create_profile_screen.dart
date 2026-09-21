import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/mock_data.dart';
import '../../services/auth_service.dart';
import '../../utils/pet_tags.dart';
import '../main_screen.dart';

/// บังคับให้กรอกโปรไฟล์หลังล็อกอินครั้งแรก (บัญชีที่ยังไม่มี displayName)
/// ไม่มีปุ่มย้อนกลับ เพราะเป็นขั้นตอนบังคับก่อนเข้าใช้งานแอป
class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController lineController = TextEditingController();
  final TextEditingController fbController = TextEditingController();

  String selectedHomeType = homeTypes.first;
  final List<String> selectedTraitIds = [];
  bool _isSaving = false;

  Uint8List? _pickedImageBytes;
  String _pickedImageContentType = 'image/jpeg';

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _pickedImageBytes = bytes;
      _pickedImageContentType = file.mimeType ?? 'image/jpeg';
    });
  }

  void _toggleTrait(String tagId) {
    setState(() {
      if (selectedTraitIds.contains(tagId)) {
        selectedTraitIds.remove(tagId);
      } else {
        selectedTraitIds.add(tagId);
      }
    });
  }

  Future<void> _saveProfile() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('กรุณากรอกชื่อผู้ใช้ / ชื่อเล่น')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      String? imageUrl;
      if (_pickedImageBytes != null) {
        imageUrl = await AuthService.instance.uploadProfileImage(
          _pickedImageBytes!,
          contentType: _pickedImageContentType,
        );
      }
      await AuthService.instance.completeProfile(
        displayName: name,
        extraFields: {
          'phone': phoneController.text.trim(),
          'lineId': lineController.text.trim(),
          'fbLink': fbController.text.trim(),
          'homeType': selectedHomeType,
          'traits': selectedTraitIds,
          if (imageUrl != null) 'profileImageUrl': imageUrl,
        },
      );
      currentUserProfile['name'] = name;
      currentUserProfile['phone'] = phoneController.text.trim();
      currentUserProfile['lineId'] = lineController.text.trim();
      currentUserProfile['fbLink'] = fbController.text.trim();
      currentUserProfile['homeType'] = selectedHomeType;
      currentUserProfile['traits'] = List<String>.from(selectedTraitIds);
      if (imageUrl != null) currentUserProfile['profileImageUrl'] = imageUrl;
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกไม่สำเร็จ กรุณาลองใหม่อีกครั้ง')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    lineController.dispose();
    fbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: GestureDetector(
                  onTap: _isSaving ? null : _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                              color: const Color(0xFFFF9E68), width: 2),
                        ),
                        child: _pickedImageBytes != null
                            ? ClipOval(
                                child: Image.memory(_pickedImageBytes!,
                                    width: 110, height: 110, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.person,
                                size: 56, color: Color(0xFFFFB085)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF9E68),
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                              BorderSide(color: Colors.white, width: 2)),
                        ),
                        child: const Icon(Icons.add_a_photo,
                            color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _pickedImageBytes == null
                    ? 'แตะเพื่อเลือกรูปโปรไฟล์ (ไม่บังคับ)'
                    : 'แตะเพื่อเปลี่ยนรูปโปรไฟล์',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
              const SizedBox(height: 12),
              const Text(
                'สร้างโปรไฟล์ของคุณ',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9E68)),
              ),
              const SizedBox(height: 4),
              const Text(
                'กรอกข้อมูลก่อนเริ่มใช้งาน PetPaws',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: nameController,
                enabled: !_isSaving,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'ชื่อผู้ใช้ / ชื่อเล่น *',
                  prefixIcon:
                      const Icon(Icons.badge, color: Color(0xFFFFB085)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('ข้อมูลการติดต่อ',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                enabled: !_isSaving,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'เบอร์โทรศัพท์',
                  prefixIcon: const Icon(Icons.phone),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lineController,
                enabled: !_isSaving,
                decoration: InputDecoration(
                  labelText: 'LINE ID',
                  prefixIcon: const Icon(Icons.chat_bubble_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: fbController,
                enabled: !_isSaving,
                decoration: InputDecoration(
                  labelText: 'ชื่อ Facebook',
                  hintText: 'เช่น สมชาย ใจดี',
                  prefixIcon: const Icon(Icons.facebook),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('ข้อมูลเสริมคัดกรองผู้เลี้ยง',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedHomeType,
                decoration: InputDecoration(
                    labelText: 'ประเภทที่พักอาศัย',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none)),
                items: homeTypes
                    .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                    .toList(),
                onChanged: _isSaving
                    ? null
                    : (val) => setState(() => selectedHomeType = val!),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('ไลฟ์สไตล์ / นิสัยของคุณ',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: petTags.map((tag) {
                  final isSelected = selectedTraitIds.contains(tag.id);
                  return ChoiceChip(
                    label: Text(tag.label,
                        style: TextStyle(
                            color:
                                isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal)),
                    selected: isSelected,
                    onSelected:
                        _isSaving ? null : (_) => _toggleTrait(tag.id),
                    selectedColor: const Color(0xFFFF9E68),
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9E68),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 2,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('บันทึกและเริ่มใช้งาน',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
