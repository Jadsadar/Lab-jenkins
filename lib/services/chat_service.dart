import 'dart:async';

import '../shared/api_client.dart';

/// จัดการแชทผ่าน REST API ของ backend
///
/// ⚠️ ยังไม่มี WebSocket ในรอบนี้ (ดู ROADMAP.md Phase 7.6-7.7) — ข้อความใหม่และ
/// unread badge อัปเดตด้วย "polling" (เรียก API ซ้ำเป็นช่วง ๆ) แทน stream แบบ
/// เรียลไทม์ที่ Firestore เคยให้ฟรี ผลคือข้อความใหม่จะขึ้นช้ากว่าเดิมสูงสุด
/// เท่ากับ [_pollInterval] ไม่ใช่ทันทีที่อีกฝั่งกดส่ง
class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final ApiClient _api = ApiClient.instance;

  static const _pollInterval = Duration(seconds: 4);

  /// สร้างห้องแชทถ้ายังไม่มี พร้อมข้อความแรกในธุรกรรมเดียวกัน (ตาม SKILL.md
  /// "ห้องแชทเกิดตอนผู้ใช้กดส่งข้อความแรกเท่านั้น") หรือถ้ามีห้องอยู่แล้ว
  /// จะแนบข้อความนี้ต่อท้ายห้องเดิมให้เลย คืนค่า chatId เสมอ
  Future<String> createOrSend({required String petId, required String message}) async {
    final res = await _api.post('/chats', body: {'petId': petId, 'message': message})
        as Map<String, dynamic>;
    return res['chatId'] as String;
  }

  /// รายการห้องแชททั้งหมดของฉัน กรองด้วยชื่อสัตว์ได้ (ใช้ตอนเจ้าของเปิดดูเฉพาะ
  /// แชทของประกาศตัวนั้น) — ก๊อปพฤติกรรมเดิมจาก chatsForDogStream ที่กรองด้วย
  /// "ชื่อ" ไม่ใช่ petId ตรง ๆ เพราะ ChatInboxScreen ยังรับแค่พารามิเตอร์ dogName
  Future<List<Map<String, dynamic>>> myChats({String? petName}) async {
    final res = await _api.get(
      '/chats',
      query: petName == null ? null : {'petName': petName},
    ) as List;
    return res.cast<Map<String, dynamic>>();
  }

  /// หาห้องแชทเดิมของประกาศนี้ คืน null ถ้ายังไม่เคยคุยกัน
  ///
  /// หน้าที่มีปุ่ม "ทักแชท" (Discover / รายการที่สนใจ / รายละเอียดสัตว์) ไม่รู้ chatId
  /// จึงเปิด ChatScreen มาแบบ chatId = null — ถ้าไม่หาห้องเดิมให้ก่อน ผู้ใช้จะเห็น
  /// ห้องว่างทั้งที่เคยคุยกันไปแล้ว
  ///
  /// ต้องเทียบ otherUserId ด้วย ไม่ใช่แค่ petId เพราะเจ้าของประกาศตัวเดียวกัน
  /// มีห้องแชทกับผู้สนใจได้หลายคนพร้อมกัน
  Future<String?> findChatForPet({
    required String petId,
    required String otherUserId,
  }) async {
    for (final chat in await myChats()) {
      if (chat['petId'] == petId && chat['otherUserId'] == otherUserId) {
        return chat['id'] as String?;
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> messages(String chatId) async {
    final res = await _api.get('/chats/$chatId/messages') as List;
    return res.cast<Map<String, dynamic>>();
  }

  Future<void> sendMessage(String chatId, String text) =>
      _api.post('/chats/$chatId/messages', body: {'text': text});

  Future<void> markRead(String chatId) => _api.post('/chats/$chatId/read');

  Future<int> _fetchUnreadCount() async {
    final res = await _api.get('/chats/unread-count') as Map<String, dynamic>;
    return res['count'] as int;
  }

  int _lastUnreadCount = 0;
  Stream<int>? _sharedUnreadStream;

  /// badge จำนวนแชทที่ยังไม่ได้อ่าน (bottom nav / app bar) — poll ทุก [_pollInterval]
  ///
  /// ⚠️ ต้องเป็น stream "ตัวเดียว" ที่ใช้ร่วมกันทั้งแอป เพราะหน้าจอที่เรียกอยู่
  /// (main_screen + profile_screen อีก 2 จุด) เรียกฟังก์ชันนี้ใน build() ซึ่งรันใหม่
  /// ทุกครั้งที่ setState — ถ้าคืน generator ตัวใหม่ทุกครั้ง จะได้ polling loop
  /// ซ้อนกันเพิ่มขึ้นเรื่อย ๆ (ตัวเก่ายังไม่ตายจนกว่าจะครบ delay 4 วิ) ยิง HTTP
  /// รัวจนแอปค้าง — cache ไว้ตัวเดียวแล้วแจกเป็น broadcast แทน
  ///
  /// onCancel เป็น no-op เพื่อไม่ให้ source ถูกยกเลิกตอนคนฟังคนสุดท้ายหลุด
  /// (ไม่งั้นพอมีคนฟังใหม่ stream จะตายไปแล้วใช้ต่อไม่ได้)
  Stream<int> unreadChatCountStream() async* {
    yield _lastUnreadCount; // ค่าล่าสุดทันที ไม่ต้องรอรอบ poll ถัดไป
    yield* _sharedUnreadStream ??=
        _pollUnreadCount().asBroadcastStream(onCancel: (_) {});
  }

  Stream<int> _pollUnreadCount() async* {
    while (true) {
      try {
        _lastUnreadCount = await _fetchUnreadCount();
      } catch (_) {
        _lastUnreadCount = 0;
      }
      yield _lastUnreadCount;
      await Future.delayed(_pollInterval);
    }
  }

  /// ข้อความในห้องแบบ poll ต่อเนื่อง ใช้แทน messagesStream ของ Firestore เดิม
  Stream<List<Map<String, dynamic>>> pollMessages(String chatId) async* {
    while (true) {
      try {
        yield await messages(chatId);
      } catch (_) {
        // เน็ตหลุดชั่วคราว ไม่ต้องล้มทั้ง stream แค่ข้ามรอบนี้ไป
      }
      await Future.delayed(_pollInterval);
    }
  }

  /// รายการห้องแชทแบบ poll ต่อเนื่อง ใช้แทน myChatsStream/chatsForDogStream เดิม
  Stream<List<Map<String, dynamic>>> pollChats({String? petName}) async* {
    while (true) {
      try {
        yield await myChats(petName: petName);
      } catch (_) {}
      await Future.delayed(_pollInterval);
    }
  }
}
