import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../widgets/pet_avatar.dart';
import 'chat_screen.dart';

class ChatInboxScreen extends StatefulWidget {
  final String dogName;

  const ChatInboxScreen({super.key, required this.dogName});

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen> {
  late List<Map<String, dynamic>> inboxChats;

  @override
  void initState() {
    super.initState();
    // กรองเฉพาะแชทของน้องหมาตัวนี้
    inboxChats = mockInboxChats
        .where((chat) => chat['dogName'] == widget.dogName)
        .toList();
  }

  int get totalUnread =>
      inboxChats.fold(0, (sum, chat) => sum + (chat['unread'] as int));

  @override
  Widget build(BuildContext context) {
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
            Text('น้อง${widget.dogName}',
                style: const TextStyle(fontSize: 12, color: Colors.black45)),
          ],
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFFFF9E68)),
        elevation: 1,
        actions: [
          if (totalUnread > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9E68),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$totalUnread ข้อความใหม่',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: inboxChats.isEmpty
          ? const Center(
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
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: inboxChats.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
              itemBuilder: (context, index) {
                final chat = inboxChats[index];
                final unread = chat['unread'] as int;

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: Stack(
                    children: [
                      PetAvatar(
                        imageUrl: chat['customerAvatar'],
                        radius: 28,
                        icon: Icons.person,
                      ),
                      if (unread > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF9E68),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$unread',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat['customerName'],
                        style: TextStyle(
                          fontWeight:
                              unread > 0 ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        chat['time'],
                        style: TextStyle(
                          fontSize: 12,
                          color: unread > 0
                              ? const Color(0xFFFF9E68)
                              : Colors.grey,
                          fontWeight:
                              unread > 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    chat['lastMessage'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unread > 0 ? Colors.black87 : Colors.grey,
                      fontWeight:
                          unread > 0 ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    // อ่านแล้ว → reset unread ที่ global (badge ทุกจอตามอัตโนมัติ)
                    // inboxChats ถือ Map ก้อนเดียวกับ mockInboxChats
                    // จึงเห็นค่าใหม่ทันที เหลือแค่สั่ง rebuild หน้านี้
                    setState(() => markChatAsRead(chat['chatId']));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          dogName: chat['dogName'],
                          isOwnerMode: true,
                          customerName: chat['customerName'],
                          customerAvatar: chat['customerAvatar'],
                          initialMessages:
                              List<Map<String, dynamic>>.from(chat['messages']),
                          onNewMessage: (msg) {
                            // อัปเดต lastMessage เมื่อส่งข้อความใหม่
                            setState(() {
                              inboxChats[index]['lastMessage'] = msg;
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
