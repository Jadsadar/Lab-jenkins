import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/demo_seed.dart';
import '../../utils/pet_tags.dart';
import '../../widgets/pet_avatar.dart';
import '../../widgets/pet_network_image.dart';
import '../detail/pet_detail_screen.dart';

/// หน้าโปรไฟล์ของผู้ใช้คนอื่น เปิดได้จากประกาศสัตว์เลี้ยงหรือจากห้องแชท
///
/// ถ้า uid ตรงกับ demoUsers (ดู lib/data/demo_seed.dart) จะใช้ข้อมูลจำลองแทน
/// เพราะยังไม่มี collection pets ใน Firestore จริง — ลบเงื่อนไขนี้ทิ้งได้เมื่อต่อจริงแล้ว
/// ไม่งั้นจะอ่านโปรไฟล์จาก Firestore ตามปกติ ส่วนประกาศของเจ้าของส่งเข้ามาจากหน้าที่เรียก
class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({
    super.key,
    required this.uid,
    this.fallbackName = 'เจ้าของ',
    this.ownerPets = const [],
  });

  final String uid;
  final String fallbackName;
  final List<Map<String, dynamic>> ownerPets;

  @override
  Widget build(BuildContext context) {
    final demoProfile = demoUsers[uid];
    if (demoProfile != null) {
      // DEMO SEED: ดึงประกาศทั้งหมดของเจ้าของจำลองจาก demoPets เองเสมอ
      // ไม่พึ่งพา ownerPets ที่หน้าเรียกมาส่งมาให้ เพราะบางที่ (เช่นหน้าแชท)
      // ไม่รู้จักรายการสัตว์เลี้ยงทั้งหมดของเจ้าของ จึงส่งมาว่างเปล่า
      final petsOfOwner =
          demoPets.where((pet) => pet['ownerId'] == uid).toList();
      return _scaffold(context, demoProfile, petsOfOwner);
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFFFFF6F0),
            appBar: _appBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final profile = snapshot.data?.data() ?? const <String, dynamic>{};
        return _scaffold(context, profile, ownerPets);
      },
    );
  }

  AppBar _appBar() => AppBar(
        title: const Text('โปรไฟล์ผู้ใช้',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFFF9E68))),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFFFF9E68)),
        elevation: 1,
        centerTitle: true,
      );

  Widget _scaffold(BuildContext context, Map<String, dynamic> profile,
      List<Map<String, dynamic>> pets) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F0),
      appBar: _appBar(),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _header(profile),
          const SizedBox(height: 24),
          _traits(profile),
          _contact(context, profile),
          const Divider(height: 40, color: Colors.black12),
          Text('ประกาศหาบ้านของผู้ใช้นี้ (${pets.length})',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF9E68))),
          const SizedBox(height: 16),
          if (pets.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('ยังไม่มีประกาศอื่นให้ดู',
                    style: TextStyle(color: Colors.black45)),
              ),
            )
          else
            ...pets.map((pet) => _petTile(context, pet, pets)),
        ],
      ),
    );
  }

  Widget _header(Map<String, dynamic> profile) {
    final name = (profile['displayName'] as String?)?.trim();
    final province = profile['province'] as String?;
    return Column(
      children: [
        PetAvatar(
          imageUrl: profile['profileImageUrl'] as String?,
          radius: 48,
          icon: Icons.person,
        ),
        const SizedBox(height: 12),
        Text(name == null || name.isEmpty ? fallbackName : name,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        if (province != null && province.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on,
                  size: 16, color: Color(0xFFFF9E68)),
              const SizedBox(width: 4),
              Text(province,
                  style: const TextStyle(color: Colors.black54, fontSize: 14)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _traits(Map<String, dynamic> profile) {
    final ids = (profile['traits'] as List?)?.map((e) => e.toString()).toList();
    if (ids == null || ids.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: tagLabels(ids)
            .map((label) => Chip(
                  label: Text(label,
                      style: const TextStyle(
                          color: Color(0xFFFF9E68),
                          fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.white,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ))
            .toList(),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('คัดลอก $label แล้ว'),
        duration: const Duration(seconds: 1)));
  }

  /// แสดงเฉพาะช่องทางที่เจ้าของกรอกไว้เอง ไม่โชว์เบอร์โทรในหน้าสาธารณะ
  /// LINE กับ Facebook กดคัดลอกได้ เพราะเป็นโปรไฟล์ของคนอื่น ไม่ใช่ของตัวเอง
  Widget _contact(BuildContext context, Map<String, dynamic> profile) {
    final lineId = (profile['lineId'] as String?)?.trim() ?? '';
    final fbLink = (profile['fbLink'] as String?)?.trim() ?? '';
    if (lineId.isEmpty && fbLink.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          if (lineId.isNotEmpty)
            _contactRow(
              context: context,
              icon: Icons.chat_bubble_outline,
              text: 'LINE: $lineId',
              onCopy: () => _copyToClipboard(context, 'LINE ID', lineId),
            ),
          if (lineId.isNotEmpty && fbLink.isNotEmpty)
            const Divider(height: 1, color: Colors.black12),
          if (fbLink.isNotEmpty)
            _contactRow(
              context: context,
              icon: Icons.facebook,
              text: fbLink,
              onCopy: () => _copyToClipboard(context, 'ชื่อ Facebook', fbLink),
            ),
        ],
      ),
    );
  }

  Widget _contactRow({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFF9E68)),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            tooltip: 'คัดลอก',
            visualDensity: VisualDensity.compact,
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }

  Widget _petTile(BuildContext context, Map<String, dynamic> pet,
      List<Map<String, dynamic>> pets) {
    final isAdopted = pet['status'] == 'ถูกรับเลี้ยงแล้ว';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: PetNetworkImage(
            imageUrl: pet['imageUrl'] as String?,
            width: 56,
            height: 56,
            iconSize: 28,
          ),
        ),
        title: Text(pet['name']?.toString() ?? 'ไม่ระบุชื่อ',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '${pet['breed'] ?? '-'} · ${pet['age'] ?? '-'}'
            '${isAdopted ? ' · ถูกรับเลี้ยงแล้ว' : ''}',
            style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFFF9E68)),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetDetailScreen(
              dog: pet,
              isMyPost: false,
              isFavorited: false,
              onToggleFavorite: () {},
              knownPets: pets,
            ),
          ),
        ),
      ),
    );
  }
}
