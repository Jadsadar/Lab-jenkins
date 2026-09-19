import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../widgets/pet_avatar.dart';
import 'chat_screen.dart';

class ChatInboxScreen extends StatelessWidget {
  /// ถ้าระบุ = โหมดเจ้าของดูแชทของสัตว์เลี้ยงตัวนี้ตัวเดียว
  /// ถ้าไม่ระบุ (null) = โหมดข้อความทั้งหมดของฉัน (ทุกตัว)
  final String? dogName;

  const ChatInboxScreen({super.key, this.dogName});

  String _otherUid(Map<String, dynamic> data, String myUid) {
    final participants = List<String>.from(data['participants'] as List);
    return participants.firstWhere((id) => id != myUid, orElse: () => '');
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final date = ts.toDate();
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return DateFormat.Hm().format(date);
    }
    return DateFormat('d MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final myUid = AuthService.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F0),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('กล่องข้อความ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9E68),
                    fontSize: 18)),
            Text(dogName == null ? 'ข้อความทั้งหมด' : 'น้อง$dogName',
                style: const TextStyle(fontSize: 12, color: Colors.black45)),
          ],
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFFFF9E68)),
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: dogName == null
            ? ChatService.instance.myChatsStream()
            : ChatService.instance.chatsForDogStream(dogName!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text('โหลดกล่องข้อความไม่สำเร็จ ลองใหม่อีกครั้ง'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data!.docs;
          if (chats.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 64, color: Colors.black12),
                  SizedBox(height: 16),
                  Text('ยังไม่มีคนทักมาเลย',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('แชร์โพสต์เพื่อให้คนรู้จักน้องมากขึ้นนะครับ',
                      style: TextStyle(fontSize: 13, color: Colors.black38)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
            itemBuilder: (context, index) {
              final doc = chats[index];
              final data = doc.data();
              final otherUid = _otherUid(data, myUid);
              final names =
                  data['participantNames'] as Map<String, dynamic>? ?? {};
              final otherName = names[otherUid] as String? ?? 'ผู้สนใจรับเลี้ยง';
              final chatDogName = data['dogName'] as String? ?? dogName ?? '';
              final lastMessage = data['lastMessage'] as String? ?? '';
              final lastMessageAt = data['lastMessageAt'] as Timestamp?;
              final lastReadMap =
                  data['lastReadAt'] as Map<String, dynamic>?;
              final lastReadAt = lastReadMap?[myUid] as Timestamp?;
              final isUnread = lastMessage.isNotEmpty &&
                  lastMessageAt != null &&
                  (lastReadAt == null ||
                      lastMessageAt.compareTo(lastReadAt) > 0);

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: Stack(
                  children: [
                    const PetAvatar(imageUrl: '', radius: 28, icon: Icons.person),
                    if (isUnread)
                      const Positioned(
                        right: 0,
                        top: 0,
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor: Color(0xFFFF9E68),
                        ),
                      ),
                  ],
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      otherName,
                      style: TextStyle(
                        fontWeight:
                            isUnread ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _formatTime(lastMessageAt),
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isUnread ? const Color(0xFFFF9E68) : Colors.grey,
                        fontWeight:
                            isUnread ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  dogName == null
                      ? 'น้อง$chatDogName • ${lastMessage.isEmpty ? "เริ่มการสนทนาแล้ว" : lastMessage}'
                      : (lastMessage.isEmpty ? 'เริ่มการสนทนาแล้ว' : lastMessage),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isUnread ? Colors.black87 : Colors.grey,
                    fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: doc.id,
                        dogName: chatDogName,
                        otherUserName: otherName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
