import 'package:flutter/material.dart';

import '../../data/demo_seed.dart';
import '../../widgets/pet_avatar.dart';
import '../profile/user_profile_screen.dart';

/// แชทตัวอย่างสำหรับคุยกับผู้ใช้จำลอง (demoUsers) ล้วนๆ อยู่ในหน่วยความจำ
/// ไม่แตะ Firestore เลย ปิดแอปแล้วข้อความหาย และพิมพ์ยังไงก็ไม่มีใครตอบจริง
///
/// ใช้แทน ChatScreen ชั่วคราวตอนคู่สนทนาเป็น demo user เท่านั้น เพราะ ChatScreen
/// จริงต้องพึ่งกฎ Firestore ที่ยังไม่ได้ deploy (ดูคอมเมนต์ DEMO SEED)
/// ลบไฟล์นี้และจุดที่เรียกใช้ทิ้งได้พร้อมกับ demo_seed.dart
class DemoChatScreen extends StatefulWidget {
  const DemoChatScreen({
    super.key,
    required this.petId,
    required this.dogName,
    required this.otherUserId,
    required this.otherUserName,
  });

  final String petId;
  final String dogName;
  final String otherUserId;
  final String otherUserName;

  @override
  State<DemoChatScreen> createState() => _DemoChatScreenState();
}

class _DemoChatScreenState extends State<DemoChatScreen> {
  late final List<Map<String, dynamic>> _messages;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages = List<Map<String, dynamic>>.from(
        demoMessages[widget.petId] ?? const []);
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'fromMe': true, 'text': text, 'time': 'ตอนนี้'});
    });
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F0),
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(
                uid: widget.otherUserId,
                fallbackName: widget.otherUserName,
              ),
            ),
          ),
          child: Row(
            children: [
              const PetAvatar(
                imageUrl: null,
                radius: 20,
                icon: Icons.person,
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherUserName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'สัตว์เลี้ยง: ${widget.dogName}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFFF9E68),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.amber.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text(
              'นี่คือแชทตัวอย่าง ข้อความจะไม่ถูกบันทึกจริงและไม่มีใครตอบกลับ',
              style: TextStyle(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text('เริ่มการสนทนาแล้ว',
                        style: TextStyle(color: Colors.black45)))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final fromMe = msg['fromMe'] as bool;
                      return Align(
                        alignment: fromMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.7),
                          decoration: BoxDecoration(
                            color: fromMe
                                ? const Color(0xFFFF9E68)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(msg['text'] as String,
                                  style: TextStyle(
                                      color: fromMe
                                          ? Colors.white
                                          : Colors.black87)),
                              const SizedBox(height: 4),
                              Text(msg['time'] as String,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: fromMe
                                          ? Colors.white70
                                          : Colors.black38)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'พิมพ์ข้อความ...',
                        filled: true,
                        fillColor: const Color(0xFFFFF6F0),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFFFF9E68),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
