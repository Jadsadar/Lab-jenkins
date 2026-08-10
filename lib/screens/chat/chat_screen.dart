import 'package:flutter/material.dart';

import '../../widgets/pet_avatar.dart';

class ChatScreen extends StatefulWidget {
  final String dogName;
  final bool isOwnerMode;
  final String customerName;
  final String customerAvatar;
  final List<Map<String, dynamic>> initialMessages;
  final Function(String)? onNewMessage;

  const ChatScreen({
    super.key,
    required this.dogName,
    this.isOwnerMode = false,
    this.customerName = '',
    this.customerAvatar = '',
    this.initialMessages = const [],
    this.onNewMessage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessages.isNotEmpty) {
      _messages = List<Map<String, dynamic>>.from(widget.initialMessages);
    } else if (widget.isOwnerMode) {
      _messages = [
        {
          "text":
              "สวัสดีครับ สนใจรับเลี้ยงน้อง${widget.dogName} ครับ น้องยังว่างอยู่ไหมครับ?",
          "isMe": false
        },
      ];
    } else {
      _messages = [
        {
          "text": "สวัสดีครับ สนใจรับเลี้ยงน้องทักสอบถามได้เลยนะครับ/คะ 😊",
          "isMe": false
        },
      ];
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_msgController.text.trim().isEmpty) return;
    final text = _msgController.text.trim();
    setState(() {
      _messages.add({"text": text, "isMe": true});
    });
    widget.onNewMessage?.call(text);
    _msgController.clear();
    FocusScope.of(context).unfocus();
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            "text": widget.isOwnerMode
                ? "ขอบคุณที่สนใจครับ น้อง${widget.dogName}ยังว่างอยู่นะครับ 🐾 สะดวกมาดูน้องวันไหนดีครับ?"
                : "ยินดีที่ได้รู้จักครับ สะดวกให้ไปดูน้องได้เลยนะครับ ติดต่อนัดหมายได้เลยครับ",
            "isMe": false
          });
        });
        _scrollToBottom();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String appBarTitle = widget.isOwnerMode
        ? (widget.customerName.isNotEmpty
            ? widget.customerName
            : 'ผู้สนใจรับเลี้ยง')
        : 'เจ้าของ${widget.dogName}';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F0),
      appBar: AppBar(
        title: Row(
          children: [
            widget.customerAvatar.isNotEmpty
                ? PetAvatar(
                    imageUrl: widget.customerAvatar,
                    radius: 20,
                    icon: Icons.person,
                    backgroundColor: Colors.white,
                  )
                : const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: Icon(Icons.person,
                        color: Color(0xFFFF9E68), size: 22),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appBarTitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'น้อง${widget.dogName}',
                    style:
                        const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFF9E68),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          // ส่วนแสดงข้อความ
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFFF9E68) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isMe ? 20 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 20),
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4)
                      ],
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),

          // กล่องพิมพ์ข้อความ
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'พิมพ์ข้อความ...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        color: Color(0xFFFF9E68), shape: BoxShape.circle),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
