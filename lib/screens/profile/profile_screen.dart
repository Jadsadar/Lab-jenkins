import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../widgets/pet_avatar.dart';
import '../chat/chat_inbox_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  final TextEditingController phoneController =
      TextEditingController(text: currentUserProfile['phone']);
  final TextEditingController lineController =
      TextEditingController(text: currentUserProfile['lineId']);
  final TextEditingController fbController =
      TextEditingController(text: currentUserProfile['fbLink']);

  String currentHomeType = currentUserProfile['homeType'];
  String currentRole = currentUserProfile['role'];

  final List<String> homeTypes = [
    'บ้านเดี่ยว',
    'ทาวน์โฮม/ทาวน์เฮ้าส์',
    'คอนโดมิเนียม',
    'อพาร์ทเม้นท์/ห้องเช่า'
  ];
  final List<String> roles = [
    'ฉันอยากหาหมาไปเลี้ยง (Adopter)',
    'ฉันมีน้องหมาอยากหาบ้านให้ (Owner/Shelter)'
  ];

  final List<String> availableTraits = [
    'สายลุย',
    'สายชิล',
    'ชอบอยู่บ้าน',
    'ชอบวิ่งเล่น',
    'รักเด็ก',
    'ติดคน',
    'รักความสงบ',
    'สายสปอร์ต'
  ];
  late List<String> selectedTraits;

  @override
  void initState() {
    super.initState();
    selectedTraits = List<String>.from(currentUserProfile['traits'] ?? []);
  }

  void toggleTrait(String trait) {
    if (!_isEditing) return;
    setState(() {
      if (selectedTraits.contains(trait)) {
        selectedTraits.remove(trait);
      } else {
        selectedTraits.add(trait);
      }
    });
  }

  void saveProfileData() {
    setState(() {
      currentUserProfile['phone'] = phoneController.text;
      currentUserProfile['lineId'] = lineController.text;
      currentUserProfile['fbLink'] = fbController.text;
      currentUserProfile['homeType'] = currentHomeType;
      currentUserProfile['role'] = currentRole;
      currentUserProfile['traits'] = selectedTraits;
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('บันทึกข้อมูลโปรไฟล์เรียบร้อยแล้ว!'),
        duration: Duration(seconds: 2)));
  }

  void startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  /// เปิดกล่องข้อความ (badge อัปเดตเองผ่าน unreadCounter ไม่ต้อง setState ตอนกลับ)
  void _openInbox() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChatInboxScreen(dogName: 'ลาเต้'),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('โปรไฟล์ของฉัน',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFFF9E68))),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        // badge แจ้งเตือนแชทที่ AppBar
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: unreadCounter,
            builder: (context, totalUnread, _) {
              if (totalUnread == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: _openInbox,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.notifications,
                          color: Color(0xFFFF9E68), size: 28),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$totalUnread',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                PetAvatar(
                  imageUrl: currentUserProfile['profileImageUrl'],
                  radius: 60,
                  icon: Icons.person,
                ),
                if (_isEditing)
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('กำลังเปิดแกลเลอรี่เพื่อเลือกรูปภาพ...'),
                            duration: Duration(seconds: 2))),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9E68),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(currentUserProfile['name'],
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9E68))),
            Text(currentUserProfile['email'],
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
            Chip(
              avatar:
                  const Icon(Icons.location_on, color: Colors.white, size: 16),
              label: Text(currentUserProfile['province'],
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: const Color(0xFFFFB085),
              side: BorderSide.none,
            ),

            // ===== แบนเนอร์แชทรอการตอบกลับ =====
            ValueListenableBuilder<int>(
              valueListenable: unreadCounter,
              builder: (context, totalUnread, _) {
                if (totalUnread == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: GestureDetector(
                    onTap: _openInbox,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9E68).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFFF9E68).withOpacity(0.4),
                            width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF9E68),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chat,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'มีข้อความใหม่ $totalUnread ข้อความ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFFFF9E68)),
                                ),
                                const Text(
                                  'มีคนสนใจรับเลี้ยงน้องของคุณ กดเพื่อดูแชท',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: Color(0xFFFF9E68)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(color: Colors.black12),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ไลฟ์สไตล์ / นิสัยของคุณ',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              alignment: WrapAlignment.start,
              children: availableTraits.map((trait) {
                final isSelected = selectedTraits.contains(trait);
                return ChoiceChip(
                  label: Text(trait,
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal)),
                  selected: isSelected,
                  onSelected:
                      _isEditing ? (selected) => toggleTrait(trait) : null,
                  selectedColor: const Color(0xFFFF9E68),
                  backgroundColor: const Color(0xFFFFF6F0),
                  disabledColor: isSelected
                      ? const Color(0xFFFF9E68).withOpacity(0.65)
                      : const Color(0xFFFFF6F0),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.black12),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ข้อมูลการติดต่อ',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  labelText: 'เบอร์โทรศัพท์',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lineController,
              enabled: _isEditing,
              decoration: InputDecoration(
                  labelText: 'LINE ID',
                  prefixIcon: const Icon(Icons.chat_bubble_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: fbController,
              enabled: _isEditing,
              decoration: InputDecoration(
                  labelText: 'ลิงก์ Facebook',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ข้อมูลเสริมคัดกรองผู้เลี้ยง',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: currentHomeType,
              disabledHint: Text(currentHomeType),
              decoration: InputDecoration(
                  labelText: 'ประเภทที่พักอาศัย',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
              items: homeTypes
                  .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                  .toList(),
              onChanged: _isEditing
                  ? (val) => setState(() => currentHomeType = val!)
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: currentRole,
              isExpanded: true,
              disabledHint: Text(
                currentRole,
                style: const TextStyle(fontSize: 13),
              ),
              decoration: InputDecoration(
                  labelText: 'บทบาทหลักในการเข้าใช้แอป',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16))),
              items: roles
                  .map((r) => DropdownMenuItem(
                      value: r,
                      child: Text(r, style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: _isEditing
                  ? (val) => setState(() => currentRole = val!)
                  : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isEditing ? saveProfileData : startEditing,
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                label: Text(_isEditing ? 'บันทึกข้อมูล' : 'แก้ไขข้อมูล',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9E68),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
