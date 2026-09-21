/// แท็กนิสัยชุดเดียวที่ใช้ร่วมกันทั้งฝั่งผู้ใช้และฝั่งสัตว์เลี้ยง
/// ผู้ใช้เลือกแท็กของตัวเอง สัตว์เลี้ยงก็ติดแท็กจากรายการเดียวกันนี้
/// เวลาจัดฟีดจึงจับคู่กันตรงๆ ได้ว่าแท็กไหนตรงกันบ้าง
class PetTag {
  const PetTag(this.id, this.label);

  /// id ภาษาอังกฤษ ใช้เก็บลงฐานข้อมูล เปลี่ยนคำแสดงผลทีหลังได้โดยไม่ต้องแก้ข้อมูลเก่า
  final String id;

  /// คำภาษาไทยที่แสดงบนหน้าจอ
  final String label;
}

const List<PetTag> petTags = [
  PetTag('energetic', 'พลังเยอะ'),
  PetTag('chill', 'สายชิล'),
  PetTag('affectionate', 'ขี้อ้อน'),
  PetTag('independent', 'รักอิสระ'),
  PetTag('talkative', 'ช่างคุย'),
  PetTag('quiet', 'รักความสงบ'),
  PetTag('social', 'เข้าสังคมเก่ง'),
  PetTag('kid_friendly', 'รักเด็ก'),
  PetTag('foodie', 'สายกิน'),
  PetTag('tidy', 'รักความสะอาด'),
];

/// จำนวนแท็กสูงสุดที่เลือกได้ ถ้าเลือกได้ทุกอันการจัดลำดับจะไม่มีความหมาย
const int maxTagSelection = 5;

/// คำภาษาไทยของแท็ก ถ้าไม่รู้จัก id นี้จะคืนค่า id กลับไปเลย
String tagLabel(String id) {
  for (final tag in petTags) {
    if (tag.id == id) return tag.label;
  }
  return id;
}

List<String> tagLabels(Iterable<String> ids) => ids.map(tagLabel).toList();

/// อ่านแท็กออกมาจากข้อมูลสัตว์เลี้ยง ถ้ายังไม่มีฟิลด์ tags จะได้ลิสต์ว่าง
List<String> petTagIds(Map<String, dynamic> pet) =>
    (pet['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [];

/// จำนวนแท็กที่ผู้ใช้กับสัตว์เลี้ยงตรงกัน ใช้เป็นคะแนนหลักในการจัดฟีด
int tagMatchCount(List<String> userTagIds, List<String> otherTagIds) =>
    userTagIds.where(otherTagIds.contains).length;

/// แท็กที่ตรงกันในรูปคำไทย เอาไว้แสดงใต้การ์ดว่า "ตรงกับคุณ: สายชิล, ขี้อ้อน"
List<String> matchedTagLabels(
        List<String> userTagIds, Map<String, dynamic> pet) =>
    tagLabels(userTagIds.where(petTagIds(pet).contains));
