import 'package:flutter/foundation.dart';

/// ข้อมูลโปรไฟล์ของผู้ใช้ปัจจุบัน
Map<String, dynamic> currentUserProfile = {
  "name": "แพรว",
  "email": "praew@email.com",
  "province": "กรุงเทพมหานคร",
  "phone": "089-1234567",
  "lineId": "praew_line",
  "fbLink": "facebook.com/praew",
  "homeType": "บ้านเดี่ยว",
  "role": "ฉันอยากหาหมาไปเลี้ยง (Adopter)",
  "profileImageUrl":
      "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=60",
  "traits": <String>['สายชิล', 'ชอบอยู่บ้าน']
};

/// Mock Data inbox (Global เพื่อให้ badge อัปเดตได้)
List<Map<String, dynamic>> mockInboxChats = [
  {
    "chatId": "chat_1",
    "customerName": "มิน",
    "customerAvatar":
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=60",
    "dogName": "ลาเต้",
    "lastMessage": "สวัสดีครับ สนใจรับเลี้ยงน้องลาเต้ครับ ยังว่างอยู่ไหม?",
    "time": "10:30",
    "unread": 2,
    "messages": [
      {
        "text": "สวัสดีครับ สนใจรับเลี้ยงน้องลาเต้ครับ ยังว่างอยู่ไหม?",
        "isMe": false
      },
    ]
  },
  {
    "chatId": "chat_2",
    "customerName": "ต้น",
    "customerAvatar":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=60",
    "dogName": "ลาเต้",
    "lastMessage": "น้องฉีดวัคซีนครบแล้วยังครับ?",
    "time": "เมื่อวาน",
    "unread": 0,
    "messages": [
      {"text": "สนใจน้องลาเต้มากเลยครับ", "isMe": false},
      {"text": "ยินดีต้อนรับเลยครับ น้องน่ารักมาก", "isMe": true},
      {"text": "น้องฉีดวัคซีนครบแล้วยังครับ?", "isMe": false},
    ]
  },
  {
    "chatId": "chat_3",
    "customerName": "ฝน",
    "customerAvatar":
        "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=100&q=60",
    "dogName": "ลาเต้",
    "lastMessage": "อยากมาดูน้องก่อนได้ไหมคะ?",
    "time": "จ. ที่แล้ว",
    "unread": 1,
    "messages": [
      {
        "text": "หวัดดีค่ะ เห็นโพสต์น้องลาเต้แล้วน่ารักมากเลยค่ะ",
        "isMe": false
      },
      {"text": "ขอบคุณมากเลยครับ น้องน่ารักมากเลย 😊", "isMe": true},
      {"text": "อยากมาดูน้องก่อนได้ไหมคะ?", "isMe": false},
    ]
  },
];

int getTotalUnread() =>
    mockInboxChats.fold(0, (sum, c) => sum + (c['unread'] as int));

/// ตัวนับข้อความที่ยังไม่ได้อ่าน แบบที่ "ประกาศตัวเองได้"
/// หน้าไหนอยากโชว์ badge ให้ฟังตัวนี้ผ่าน ValueListenableBuilder
/// จะได้อัปเดตทันทีที่มีการอ่านแชท ไม่ต้องรอ setState ของหน้านั้นๆ
final ValueNotifier<int> unreadCounter = ValueNotifier<int>(getTotalUnread());

/// ทำเครื่องหมายว่าอ่านแชทนี้แล้ว พร้อมแจ้ง badge ทุกจุดให้อัปเดตตาม
void markChatAsRead(String chatId) {
  final index = mockInboxChats.indexWhere((c) => c['chatId'] == chatId);
  if (index == -1) return;
  mockInboxChats[index]['unread'] = 0;
  unreadCounter.value = getTotalUnread();
}

const List<String> thaiProvinces = [
  'กรุงเทพมหานคร',
  'กระบี่',
  'กาญจนบุรี',
  'กาฬสินธุ์',
  'กำแพงเพชร',
  'ขอนแก่น',
  'จันทบุรี',
  'ฉะเชิงเทรา',
  'ชลบุรี',
  'ชัยนาท',
  'ชัยภูมิ',
  'ชุมพร',
  'เชียงราย',
  'เชียงใหม่',
  'ตรัง',
  'ตราด',
  'ตาก',
  'นครนายก',
  'นครปฐม',
  'นครพนม',
  'นครราชสีมา',
  'นครศรีธรรมราช',
  'นครสวรรค์',
  'นนทบุรี',
  'นราธิวาส',
  'น่าน',
  'บึงกาฬ',
  'บุรีรัมย์',
  'ปทุมธานี',
  'ประจวบคีรีขันธ์',
  'ปราจีนบุรี',
  'ปัตตานี',
  'พระนครศรีอยุธยา',
  'พะเยา',
  'พังงา',
  'พัทลุง',
  'พิจิตร',
  'พิษณุโลก',
  'เพชรบุรี',
  'เพชรบูรณ์',
  'แพร่',
  'ภูเก็ต',
  'มหาสารคาม',
  'มุกดาหาร',
  'แม่ฮ่องสอน',
  'ยโสธร',
  'ยะลา',
  'ร้อยเอ็ด',
  'ระนอง',
  'ระยอง',
  'ราชบุรี',
  'ลพบุรี',
  'ลำปาง',
  'ลำพูน',
  'เลย',
  'ศรีสะเกษ',
  'สกลนคร',
  'สงขลา',
  'สตูล',
  'สมุทรปราการ',
  'สมุทรสงคราม',
  'สมุทรสาคร',
  'สระแก้ว',
  'สระบุรี',
  'สิงห์บุรี',
  'สุโขทัย',
  'สุพรรณบุรี',
  'สุราษฎร์ธานี',
  'สุรินทร์',
  'หนองคาย',
  'หนองบัวลำภู',
  'อ่างทอง',
  'อำนาจเจริญ',
  'อุดรธานี',
  'อุตรดิตถ์',
  'อุทัยธานี',
  'อุบลราชธานี'
];
