import 'pet_tags.dart';

/// จัดลำดับสัตว์เลี้ยงในฟีดให้ตัวที่แท็กตรงกับผู้ใช้มากที่สุดขึ้นก่อน
/// ตัวที่ไม่ตรงเลยยังอยู่ในฟีด แค่ไปต่อท้าย
///
/// เกณฑ์ตัดสินเรียงตามลำดับ:
/// 1. จำนวนแท็กที่ตรงกัน (มากไปน้อย)
/// 2. อยู่จังหวัดเดียวกับผู้ใช้
/// 3. ประกาศใหม่ล่าสุด
///
/// ข้อ 2 กับ 3 จำเป็น เพราะถ้าคะแนนเท่ากันแล้วไม่มีตัวตัดสิน
/// ลำดับจะสลับไปมาทุกครั้งที่เปิดแอป
List<Map<String, dynamic>> sortPetsForUser(
  List<Map<String, dynamic>> pets, {
  required List<String> userTagIds,
  String userProvince = '',
}) {
  // คิดคะแนนไว้ก่อนรอบเดียว ไม่ต้องคิดซ้ำทุกครั้งที่ sort เปรียบเทียบ
  final matchScore = <String, int>{
    for (final pet in pets)
      pet['id'].toString(): tagMatchCount(userTagIds, petTagIds(pet))
  };

  final sorted = List<Map<String, dynamic>>.from(pets);
  sorted.sort((a, b) {
    final byMatch = matchScore[b['id'].toString()]!
        .compareTo(matchScore[a['id'].toString()]!);
    if (byMatch != 0) return byMatch;

    final byProvince = _sameProvince(b, userProvince)
        .compareTo(_sameProvince(a, userProvince));
    if (byProvince != 0) return byProvince;

    return _postedAt(b).compareTo(_postedAt(a));
  });
  return sorted;
}

int _sameProvince(Map<String, dynamic> pet, String userProvince) =>
    userProvince.isNotEmpty && pet['province'] == userProvince ? 1 : 0;

/// ตอนนี้ id ของประกาศคือเวลาที่สร้าง (millisecondsSinceEpoch)
/// ถ้าย้ายไปเก็บบน Firestore แล้ว ให้เปลี่ยนมาอ่านจากฟิลด์ createdAt แทน
int _postedAt(Map<String, dynamic> pet) =>
    int.tryParse(pet['id']?.toString() ?? '') ?? 0;
