import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/swipeable_card.dart';
import '../chat/chat_screen.dart';

class DiscoverScreen extends StatelessWidget {
  final List<Map<String, dynamic>> dogs;
  final Function(Map<String, dynamic>) onLike;
  final Function(Map<String, dynamic>) onPass;
  final VoidCallback onUndoPass;
  final bool canUndo;
  final List<Map<String, dynamic>> likedDogs;
  final Function(Map<String, dynamic>) onToggleFavorite;

  const DiscoverScreen({
    super.key,
    required this.dogs,
    required this.onLike,
    required this.onPass,
    required this.onUndoPass,
    required this.canUndo,
    required this.likedDogs,
    required this.onToggleFavorite,
  });

  Future<void> _handleLikeAndChat(
      BuildContext context, Map<String, dynamic> dog) async {
    onLike(dog);

    final ownerId = dog['ownerId'] as String?;
    final myUid = AuthService.instance.currentUser?.uid;
    if (ownerId == null || ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('สัตว์เลี้ยงตัวอย่างนี้ยังไม่มีเจ้าของจริงในระบบให้แชทด้วย')));
      return;
    }
    if (ownerId == myUid) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('นี่คือประกาศของคุณเอง')));
      return;
    }
    final ownerName = dog['ownerName'] as String? ?? 'เจ้าของ';

    // ยังไม่สร้างห้องแชทตรงนี้ — แค่พาไปหน้าคุย ห้องจะถูกสร้างจริงตอนกดส่ง
    // ข้อความแรกใน ChatScreen เท่านั้น (chatId: null) ตรงตามกฎ SKILL.md ที่ว่า
    // "การกดถูกใจต้องไม่สร้างห้องแชทอัตโนมัติ"
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          petId: dog['id'] as String,
          dogName: dog['name'] as String,
          otherUserName: ownerName,
          otherUserId: ownerId,
        ),
      ),
    );
  }

  Future<void> _handleReport(
      BuildContext context, Map<String, dynamic> dog) async {
    const reasons = [
      'ข้อมูลเป็นเท็จ',
      'สแปมหรือโฆษณา',
      'เนื้อหาไม่เหมาะสม',
      'สงสัยว่าเป็นการหลอกลวง',
      'อื่นๆ',
    ];
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('รายงานประกาศนี้'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons
              .map((r) => ListTile(
                    title: Text(r),
                    onTap: () => Navigator.pop(context, r),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
        ],
      ),
    );
    if (reason == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('ส่งรายงานเรียบร้อยแล้ว ขอบคุณที่ช่วยดูแลชุมชนของเรา')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PetPaws',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFFF9E68))),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: dogs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ขอบคุณที่ทำให้สัตว์ทุกตัวมีบ้านที่อบอุ่น!',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  if (canUndo) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: onUndoPass,
                      icon: const Icon(Icons.replay),
                      label: const Text('ลองดูสัตว์เลี้ยงอีกครั้ง'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB085),
                          foregroundColor: Colors.white),
                    )
                  ]
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SwipeableCard(
                      dog: dogs.first,
                      onLike: () => onLike(dogs.first),
                      onPass: () => onPass(dogs.first),
                      likedDogs: likedDogs,
                      onToggleFavorite: onToggleFavorite,
                      allPets: dogs,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        heroTag: "btn_report",
                        tooltip: 'รายงาน',
                        onPressed: () => _handleReport(context, dogs.first),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey.shade500,
                        mini: true,
                        elevation: 2,
                        child: const Icon(Icons.flag_outlined, size: 24),
                      ),
                      const SizedBox(width: 24),
                      FloatingActionButton(
                        heroTag: "btn_pass",
                        onPressed: () => onPass(dogs.first),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.redAccent.shade200,
                        elevation: 2,
                        child: const Icon(Icons.close, size: 30),
                      ),
                      const SizedBox(width: 24),
                      FloatingActionButton(
                        heroTag: "btn_undo",
                        onPressed: canUndo ? onUndoPass : null,
                        backgroundColor:
                            canUndo ? Colors.white : Colors.grey[200],
                        foregroundColor: const Color(0xFFFFB085),
                        mini: true,
                        elevation: canUndo ? 2 : 0,
                        child: const Icon(Icons.replay, size: 24),
                      ),
                      const SizedBox(width: 24),
                      FloatingActionButton(
                        heroTag: "btn_like",
                        onPressed: () => onLike(dogs.first),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green.shade400,
                        elevation: 2,
                        child: const Icon(Icons.favorite, size: 30),
                      ),
                      const SizedBox(width: 24),
                      FloatingActionButton(
                        heroTag: "btn_like_chat",
                        tooltip: 'ถูกใจและแชท',
                        onPressed: () =>
                            _handleLikeAndChat(context, dogs.first),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.pink.shade300,
                        mini: true,
                        elevation: 2,
                        child: const Icon(Icons.chat_bubble, size: 24),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
