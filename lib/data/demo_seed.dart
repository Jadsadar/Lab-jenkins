// ข้อมูลจำลองชั่วคราว ใช้ดูหน้าตา "โปรไฟล์ผู้ใช้คนอื่น" และฟีดที่มีคนอื่นลงประกาศไว้
// ก่อนที่จะมี collection `pets` ใน Firestore จริง
//
// ลบไฟล์นี้และจุดที่เรียกใช้ (ดูคอมเมนต์ "DEMO SEED" ใน main_screen.dart)
// ทิ้งได้ทันทีที่ต่อประกาศสัตว์เลี้ยงเข้า Firestore จริงแล้ว

/// โปรไฟล์ผู้ใช้จำลอง 3 คน คีย์ด้วย uid ปลอม
/// หน้าโปรไฟล์ (user_profile_screen.dart) จะเช็ค map นี้ก่อนไปถาม Firestore
const Map<String, Map<String, dynamic>> demoUsers = {
  'demo_user_1': {
    'displayName': 'จินตนา ศรีสุข',
    'province': 'กรุงเทพมหานคร',
    'profileImageUrl':
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=60',
    'traits': ['quiet', 'affectionate', 'tidy'],
    'lineId': 'jintana_cat',
    'fbLink': 'Jintana Srisuk',
    'phone': '081-234-5678',
  },
  'demo_user_2': {
    'displayName': 'ธนากร ใจดี',
    'province': 'เชียงใหม่',
    'profileImageUrl':
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=60',
    'traits': ['energetic', 'social', 'foodie'],
    'lineId': 'thanakorn.d',
    'fbLink': 'Thanakorn Jaidee',
    'phone': '089-876-5432',
  },
  'demo_user_3': {
    'displayName': 'พิมพ์ชนก รักสัตว์',
    'province': 'นนทบุรี',
    'profileImageUrl':
        'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?auto=format&fit=crop&w=300&q=60',
    'traits': ['affectionate', 'kid_friendly', 'tidy'],
    'lineId': 'pimchanok.rs',
    'fbLink': 'Pimchanok Ruksat',
    'phone': '062-345-6789',
  },
};

/// ประกาศสัตว์เลี้ยงจำลอง ผูกกับ demoUsers ข้างบนผ่าน ownerId
/// จงใจให้บางคนลงมากกว่า 1 ตัว จะได้เห็นรายการ "ประกาศอื่นของเจ้าของ" ในหน้าโปรไฟล์
final List<Map<String, dynamic>> demoPets = [
  {
    'id': 'demo_pet_1',
    'ownerId': 'demo_user_1',
    'ownerName': 'จินตนา ศรีสุข',
    'name': 'มะลิ',
    'breed': 'แมวไทยขนสั้น',
    'province': 'กรุงเทพมหานคร',
    'age': '1 ปี',
    'gender': 'เมีย',
    'weight': '3.2',
    'tags': ['quiet', 'affectionate', 'tidy'],
    'story': 'มะลิเป็นแมวเรียบร้อย ชอบนอนตักและไม่ค่อยส่งเสียง เหมาะกับคนอยู่คอนโด',
    'imageUrl':
        'https://images.unsplash.com/photo-1533738363-b7f9aef128ce?auto=format&fit=crop&w=500&q=60',
    'status': 'ยังไม่ถูกรับเลี้ยง',
    'engagementLikes': 120,
  },
  {
    'id': 'demo_pet_2',
    'ownerId': 'demo_user_1',
    'ownerName': 'จินตนา ศรีสุข',
    'name': 'โคน่า',
    'breed': 'แมวส้ม',
    'province': 'กรุงเทพมหานคร',
    'age': '8 เดือน',
    'gender': 'ผู้',
    'weight': '3.5',
    'tags': ['energetic', 'foodie', 'social'],
    'story': 'โคน่าตัวป่วนประจำบ้าน ชอบวิ่งเล่นและกินเก่งมาก',
    'imageUrl':
        'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=500&q=60',
    'status': 'ยังไม่ถูกรับเลี้ยง',
    'engagementLikes': 200,
  },
  {
    'id': 'demo_pet_3',
    'ownerId': 'demo_user_2',
    'ownerName': 'ธนากร ใจดี',
    'name': 'บราวนี่',
    'breed': 'Golden Retriever',
    'province': 'เชียงใหม่',
    'age': '2 ปี',
    'gender': 'ผู้',
    'weight': '25',
    'tags': ['energetic', 'social', 'kid_friendly'],
    'story': 'บราวนี่เป็นมิตรกับทุกคน ชอบเล่นกับเด็กและสัตว์ตัวอื่น',
    'imageUrl':
        'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=500&q=60',
    'status': 'ยังไม่ถูกรับเลี้ยง',
    'engagementLikes': 340,
  },
  {
    'id': 'demo_pet_4',
    'ownerId': 'demo_user_2',
    'ownerName': 'ธนากร ใจดี',
    'name': 'คุกกี้',
    'breed': 'Poodle',
    'province': 'เชียงใหม่',
    'age': '1 ปี 3 เดือน',
    'gender': 'เมีย',
    'weight': '6',
    'tags': ['affectionate', 'foodie', 'talkative'],
    'story': 'คุกกี้ขี้อ้อนมาก ชอบเห่าทักทายและตามติดเจ้าของตลอดเวลา',
    'imageUrl':
        'https://images.unsplash.com/photo-1591160690555-5debfba289f0?auto=format&fit=crop&w=500&q=60',
    'status': 'ยังไม่ถูกรับเลี้ยง',
    'engagementLikes': 150,
  },
  {
    'id': 'demo_pet_5',
    'ownerId': 'demo_user_3',
    'ownerName': 'พิมพ์ชนก รักสัตว์',
    'name': 'ป๊อปคอร์น',
    'breed': 'Shih Tzu',
    'province': 'นนทบุรี',
    'age': '3 ปี',
    'gender': 'ผู้',
    'weight': '7',
    'tags': ['quiet', 'kid_friendly', 'tidy'],
    'story': 'ป๊อปคอร์นนิสัยดี ใจเย็น อยู่กับเด็กเล็กได้สบาย',
    'imageUrl':
        'https://images.unsplash.com/photo-1591768575198-88dac53fbd0a?auto=format&fit=crop&w=500&q=60',
    'status': 'ยังไม่ถูกรับเลี้ยง',
    'engagementLikes': 90,
  },
  {
    'id': 'demo_pet_6',
    'ownerId': 'demo_user_3',
    'ownerName': 'พิมพ์ชนก รักสัตว์',
    'name': 'ไข่มุก',
    'breed': 'แมวเปอร์เซีย',
    'province': 'นนทบุรี',
    'age': '6 เดือน',
    'gender': 'เมีย',
    'weight': '2.1',
    'tags': ['chill', 'tidy', 'affectionate'],
    'story': 'ไข่มุกสายชิล นอนเก่ง ขับถ่ายเป็นที่ เลี้ยงง่ายมาก',
    'imageUrl':
        'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=500&q=60',
    'status': 'ยังไม่ถูกรับเลี้ยง',
    'engagementLikes': 210,
  },
];

/// บทสนทนาจำลอง คีย์ด้วย id ของสัตว์เลี้ยงใน demoPets
/// เปิดผ่าน DemoChatScreen เท่านั้น ไม่แตะ Firestore เลย จึงไม่ติดปัญหา
/// deploy กฎ Firestore และไม่ทิ้งร่องรอยอะไรไว้ในฐานข้อมูลจริง
/// (ยังไม่มี pet ไหนมีบทสนทนาไว้ล่วงหน้าก็ได้ จะเริ่มจากห้องว่างแทน)
final Map<String, List<Map<String, dynamic>>> demoMessages = {
  'demo_pet_1': [
    {'fromMe': false, 'text': 'สวัสดีค่ะ สนใจรับเลี้ยงมะลิไหมคะ', 'time': '10:02'},
    {'fromMe': true, 'text': 'สวัสดีครับ สนใจครับ น้องพร้อมย้ายบ้านเมื่อไหร่ครับ', 'time': '10:05'},
    {'fromMe': false, 'text': 'พร้อมเลยค่ะ สะดวกนัดดูตัวเมื่อไหร่บอกได้เลยนะคะ', 'time': '10:07'},
  ],
  'demo_pet_3': [
    {'fromMe': false, 'text': 'บราวนี่ยังหาบ้านอยู่ไหมครับ', 'time': 'เมื่อวาน'},
    {'fromMe': true, 'text': 'ยังอยู่ครับ สนใจไหมครับ บ้านมีพื้นที่ให้วิ่งเล่นไหมครับ', 'time': 'เมื่อวาน'},
    {'fromMe': false, 'text': 'มีสวนหลังบ้านครับ กว้างพอสมควรเลย', 'time': 'เมื่อวาน'},
  ],
};
