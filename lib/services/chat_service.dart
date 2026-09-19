import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';

/// จัดการแชทจริงระหว่างผู้ใช้ 2 คนผ่าน Cloud Firestore
/// โครงสร้าง: chats/{chatId} มี participants (2 uid) + subcollection messages
class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _myUid => AuthService.instance.currentUser!.uid;

  /// สร้าง chatId แบบ deterministic จากคู่ uid + ชื่อสัตว์เลี้ยง
  /// เพื่อให้เปิดแชทเรื่องเดียวกันซ้ำแล้วได้ห้องเดิมเสมอ
  String chatIdFor({required String otherUserId, required String dogName}) {
    final ids = [_myUid, otherUserId]..sort();
    final dogSlug = dogName.trim().replaceAll(RegExp(r'\s+'), '_');
    return '${ids.join('_')}__$dogSlug';
  }

  /// สร้างห้องแชทถ้ายังไม่มี แล้วคืน chatId กลับไป
  Future<String> ensureChat({
    required String otherUserId,
    required String otherUserName,
    required String dogName,
  }) async {
    final me = AuthService.instance.currentUser!;
    final chatId = chatIdFor(otherUserId: otherUserId, dogName: dogName);
    final ref = _db.collection('chats').doc(chatId);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'participants': [me.uid, otherUserId]..sort(),
        'participantNames': {
          me.uid: me.displayName ?? 'ผู้ใช้',
          otherUserId: otherUserName,
        },
        'dogName': dogName,
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastReadAt': {me.uid: FieldValue.serverTimestamp()},
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return chatId;
  }

  /// แชททั้งหมดของฉัน เรียงตามข้อความล่าสุด
  Stream<QuerySnapshot<Map<String, dynamic>>> myChatsStream() {
    return _db
        .collection('chats')
        .where('participants', arrayContains: _myUid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

  /// แชททั้งหมดเกี่ยวกับสัตว์เลี้ยงตัวนี้ที่ฉันมีส่วนร่วม (ใช้ในหน้ากล่องข้อความของเจ้าของ)
  Stream<QuerySnapshot<Map<String, dynamic>>> chatsForDogStream(
      String dogName) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: _myUid)
        .where('dogName', isEqualTo: dogName)
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> sendMessage(String chatId, String text) async {
    final chatRef = _db.collection('chats').doc(chatId);
    await chatRef.collection('messages').add({
      'senderId': _myUid,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await chatRef.update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastReadAt.$_myUid': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markRead(String chatId) {
    return _db.collection('chats').doc(chatId).update({
      'lastReadAt.$_myUid': FieldValue.serverTimestamp(),
    });
  }

  /// นับจำนวนห้องแชทที่มีข้อความใหม่ยังไม่ได้อ่าน ไว้ใช้แสดง badge
  Stream<int> unreadChatCountStream() {
    if (AuthService.instance.currentUser == null) return Stream.value(0);
    return myChatsStream().map((snap) {
      var count = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final lastMessageAt = data['lastMessageAt'] as Timestamp?;
        final lastReadMap = data['lastReadAt'] as Map<String, dynamic>?;
        final lastReadAt = lastReadMap?[_myUid] as Timestamp?;
        if (lastMessageAt != null &&
            (lastReadAt == null || lastMessageAt.compareTo(lastReadAt) > 0)) {
          count++;
        }
      }
      return count;
    });
  }
}
