/// รายชื่อสัตว์เลี้ยงตั้งต้นที่แสดงในหน้า Discover
List<Map<String, dynamic>> initialDogs = [
  {
    "id": "15",
    "name": "เจ้านาย",
    "breed": "Siberian Husky",
    "province": "เชียงใหม่",
    "age": "3 ปี",
    "gender": "ผู้",
    "weight": "22",
    "temperament": "พูดเก่ง, พลังล้น, ตลก",
    "story": "น้องชอบเถียงมากๆ ครับ ใครหาเพื่อนคุยรับรองไม่เหงาแน่นอน",
    "imageUrl": "https://placedog.net/500/500?id=15",
    "reelUrl": "https://placedog.net/500/800?id=15",
    "status": "ยังไม่ถูกรับเลี้ยง",
    "engagementLikes": 245
  },
  {
    "id": "16",
    "name": "ชาไข่มุก",
    "breed": "French Bulldog",
    "province": "กรุงเทพมหานคร",
    "age": "1 ปี",
    "gender": "เมีย",
    "weight": "11",
    "temperament": "ขี้อ้อน, กินเก่ง, นอนกรน",
    "story": "ตัวตึงประจำบ้าน ชอบนอนตากแอร์และกินขนมเป็นชีวิตจิตใจ",
    "imageUrl":
        "https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=500&q=60",
    "reelUrl":
        "https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=500&h=800&q=80",
    "status": "ยังไม่ถูกรับเลี้ยง",
    "engagementLikes": 182
  },
  {
    "id": "19",
    "name": "หมูปิ้ง",
    "breed": "Corgi",
    "province": "นครปฐม",
    "age": "6 เดือน",
    "gender": "ผู้",
    "weight": "5.5",
    "temperament": "ขี้อ้อน, กินเก่ง, วิ่งเร็ว",
    "story":
        "น้องหมูปิ้งขาสั้นแต่สู้ชีวิตครับ ชอบกินขนมมากๆ พลังงานล้นเหลือ ใครหาเพื่อนวิ่งเล่นตอนเย็นๆ รับไปได้เลยครับ",
    "imageUrl":
        "https://images.unsplash.com/photo-1597626133663-53df9633b799?auto=format&fit=crop&w=500&q=60",
    "reelUrl":
        "https://images.unsplash.com/photo-1597626133663-53df9633b799?auto=format&fit=crop&w=500&h=800&q=80",
    "status": "ยังไม่ถูกรับเลี้ยง",
    "engagementLikes": 512
  },
  {
    "id": "20",
    "name": "กะทิ",
    "breed": "Shih Tzu",
    "province": "ระยอง",
    "age": "2 ปี",
    "gender": "เมีย",
    "weight": "4.2",
    "temperament": "เรียบร้อย, ชอบนอน, ติดเจ้าของ",
    "story":
        "น้องกะทิเป็นหมาคุณหนู ชอบนอนตากแอร์ ไม่ค่อยเห่ากวนใจ นิ่งมากๆ เหมาะกับคนอยู่คอนโดหรือพื้นที่จำกัดมากๆ ค่ะ",
    "imageUrl": "https://placedog.net/500/500?id=20",
    "reelUrl": "https://placedog.net/500/800?id=20",
    "status": "ยังไม่ถูกรับเลี้ยง",
    "engagementLikes": 89
  },
  {
    "id": "12",
    "name": "ถังหูลู่",
    "breed": "Samoyed",
    "province": "เชียงราย",
    "age": "2 ปี",
    "gender": "เมีย",
    "weight": "18",
    "temperament": "ยิ้มเก่ง, ขนฟู, ขี้เล่นสุดๆ",
    "story":
        "น้องถังหูลู่เป็นหมาอารมณ์ดี ยิ้มหวานตลอดเวลา ชอบอากาศเย็นๆ และชอบวิ่งสวนสาธารณะสุดๆ ครับ",
    "imageUrl": "https://placedog.net/500/500?id=12",
    "reelUrl": "https://placedog.net/500/800?id=12",
    "status": "ยังไม่ถูกรับเลี้ยง",
    "engagementLikes": 310
  },
  {
    "id": "1",
    "name": "โบ้",
    "breed": "Golden Retriever",
    "province": "กรุงเทพมหานคร",
    "age": "2 เดือน",
    "gender": "ผู้",
    "weight": "4.5",
    "temperament": "ร่าเริง, ขี้เล่น, เป็นมิตร, กินเก่ง",
    "story":
        "น้องโบ้เป็นหมาน้อยวัยกำลังซน ชอบเล่นลูกบอลและชอบวิ่งเล่นในสวนสาธารณะมากๆ กำลังหาบ้านที่มีพื้นที่ให้วิ่งเล่นครับ",
    "imageUrl":
        "https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=500&q=60",
    "status": "ยังไม่ถูกรับเลี้ยง",
    "engagementLikes": 140
  },
  {
    "id": "21",
    "name": "ขนมปัง",
    "breed": "Pomeranian",
    "province": "เชียงใหม่",
    "age": "8 เดือน",
    "gender": "ผู้",
    "weight": "3.2",
    "temperament": "ขนฟู, ขี้เล่น, ติดคนมาก",
    "story":
        "น้องขนมปังตัวเล็กแต่พลังเยอะ ชอบกระโดดเล่นกับเจ้าของทั้งวัน เหมาะกับคนที่อยากได้เพื่อนตัวจิ๋วไว้กอด",
    "imageUrl":
        "https://images.unsplash.com/photo-1612195583950-b8fd34c87093?auto=format&fit=crop&w=500&q=60",
    "reelUrl":
        "https://images.unsplash.com/photo-1612195583950-b8fd34c87093?auto=format&fit=crop&w=500&h=800&q=80",
    "status": "ยังไม่ถูกรับเลี้ยง",
    "engagementLikes": 402
  },
  {
    "id": "22",
    "name": "หมีน้อย",
    "breed": "Akita",
    "province": "อุดรธานี",
    "age": "1 ปี 6 เดือน",
    "gender": "ผู้",
    "weight": "28",
    "temperament": "นิ่ง, ซื่อสัตย์, รักเจ้าของคนเดียว",
    "story":
        "น้องหมีน้อยจงรักภักดีมากครับ เหมาะกับบ้านที่มีพื้นที่กว้างและมีเวลาฝึกวินัยให้น้อง",
    "imageUrl":
        "https://images.unsplash.com/photo-1561037404-61cd46aa615b?auto=format&fit=crop&w=500&q=60",
    "reelUrl":
        "https://images.unsplash.com/photo-1561037404-61cd46aa615b?auto=format&fit=crop&w=500&h=800&q=80",
    "status": "ยังไม่ถูกรับเลี้ยง",
    "engagementLikes": 115
  },
  {
    "id": "23",
    "name": "หวานใจ",
    "breed": "Beagle",
    "province": "ขอนแก่น",
    "age": "1 ปี",
    "gender": "เมีย",
    "weight": "9.5",
    "temperament": "จมูกไว, ขี้สงสัย, เห่าเก่ง",
    "story":
        "น้องหวานใจชอบดมกลิ่นสำรวจไปทั่ว ถ้าได้ไปเดินป่าหรือสวนสาธารณะจะมีความสุขมากๆ ค่ะ",
    "imageUrl":
        "https://images.unsplash.com/photo-1576201836106-db1758fd1c97?auto=format&fit=crop&w=500&q=60",
    "reelUrl":
        "https://images.unsplash.com/photo-1576201836106-db1758fd1c97?auto=format&fit=crop&w=500&h=800&q=80",
    "status": "ยังไม่ถูกรับเลี้ยง",
    "engagementLikes": 260
  },
  {
    "id": "24",
    "name": "โดนัท",
    "breed": "Pug",
    "province": "ชลบุรี",
    "age": "10 เดือน",
    "gender": "ผู้",
    "weight": "7",
    "temperament": "ขี้เกียจ, กรนเสียงดัง, น่ารักสุดๆ",
    "story":
        "น้องโดนัทชอบนอนมากกว่าวิ่ง ใครอยากได้เพื่อนแบบสายชิลล์ น้องตัวนี้เลยครับ",
    "imageUrl":
        "https://images.unsplash.com/photo-1517849845537-4d257902861a?auto=format&fit=crop&w=500&q=60",
    "reelUrl":
        "https://images.unsplash.com/photo-1517849845537-4d257902861a?auto=format&fit=crop&w=500&h=800&q=80",
    "status": "ยังไม่ถูกรับเลี้ยง",
    "engagementLikes": 380
  },
  {
    "id": "25",
    "name": "บุหงา",
    "breed": "Shiba Inu",
    "province": "สงขลา",
    "age": "1 ปี 2 เดือน",
    "gender": "เมีย",
    "weight": "10",
    "temperament": "หน้านิ่งใจร้าย, ฉลาด, รักความสะอาด",
    "story":
        "น้องบุหงาดูเฉยๆแต่จริงๆแล้วขี้อ้อนมาก ชอบนอนตากแอร์และเดินเล่นยามเย็นค่ะ",
    "imageUrl":
        "https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=500&q=60",
    "reelUrl":
        "https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=500&h=800&q=80",
    "status": "ยังไม่ถูกรับเลี้ยง",
    "engagementLikes": 99
  },
];

/// รายการประกาศของฉันตั้งต้น (mock)
List<Map<String, dynamic>> initialMyPostedDogs = [
  {
    "id": "my_1",
    "name": "ลาเต้",
    "breed": "Poodle",
    "province": "ภูเก็ต",
    "age": "4 เดือน",
    "gender": "ผู้",
    "weight": "2.5",
    "temperament": "ขี้อ้อน, พลังล้นเหลือ",
    "story": "กำลังหาบ้านที่พร้อมดูแลน้องลาเต้ครับ",
    "imageUrl":
        "https://images.unsplash.com/photo-1591160690555-5debfba289f0?auto=format&fit=crop&w=500&q=60",
    "reelUrl":
        "https://images.unsplash.com/photo-1591160690555-5debfba289f0?auto=format&fit=crop&w=500&h=800&q=80",
    "status": "ยังไม่ถูกรับเลี้ยง",
    "engagementLikes": 45
  }
];
