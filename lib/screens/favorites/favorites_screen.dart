import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/pet_avatar.dart';
import '../chat/chat_screen.dart';
import '../detail/pet_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> likedDogs;
  final Function(Map<String, dynamic>) onToggleFavorite;

  const FavoritesScreen({
    super.key,
    required this.likedDogs,
    required this.onToggleFavorite,
  });

  Future<void> _chatWithOwner(
      BuildContext context, Map<String, dynamic> dog) async {
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

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatScreen(
                  petId: dog['id'] as String,
                  dogName: dog['name'] as String,
                  otherUserName: ownerName,
                  otherUserId: ownerId,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการที่สนใจ',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFFF9E68))),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: likedDogs.isEmpty
          ? const Center(
              child: Text('ยังไม่มีสัตว์เลี้ยงที่ถูกใจเลย',
                  style: TextStyle(fontSize: 16, color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: likedDogs.length,
              itemBuilder: (context, index) {
                final dog = likedDogs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: PetAvatar(
                      imageUrl: dog['imageUrl'],
                      radius: 30,
                    ),
                    title: Text(dog['name'],
                        style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${dog['province']} • ${dog['breed']}'),
                    trailing: ElevatedButton.icon(
                      onPressed: () => _chatWithOwner(context, dog),
                      icon: const Icon(Icons.chat, size: 18),
                      label: const Text('ทักแชท'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB085),
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PetDetailScreen(
                                  dog: dog,
                                  isMyPost: false,
                                  isFavorited: likedDogs
                                      .any((d) => d['id'] == dog['id']),
                                  onToggleFavorite: () =>
                                      onToggleFavorite(dog),
                                ))),
                  ),
                );
              },
            ),
    );
  }
}
