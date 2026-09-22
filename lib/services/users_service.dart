import '../shared/api_client.dart';

/// โปรไฟล์สาธารณะของผู้ใช้คนอื่น (ใช้ในหน้าดูโปรไฟล์เจ้าของประกาศ/คู่แชท)
/// ข้อมูลของ "ตัวเอง" (เต็มรูปแบบ รวมเบอร์โทร) อยู่ใน AuthService/ProfileScreen แทน
class UsersService {
  UsersService._();
  static final UsersService instance = UsersService._();

  final ApiClient _api = ApiClient.instance;

  /// { displayName, province, profileImageUrl, traits, lineId, fbLink }
  /// ไม่มี phone เพราะ backend ไม่ส่งเบอร์โทรมาในโปรไฟล์สาธารณะ (ดู users.service.ts)
  Future<Map<String, dynamic>> getPublicProfile(String uid) async =>
      (await _api.get('/users/$uid')) as Map<String, dynamic>;

  /// โปรไฟล์เต็มของตัวเอง — คีย์ตรงกับ currentUserProfile เป๊ะ ๆ (name, province,
  /// phone, lineId, fbLink, homeType, profileImageUrl, traits) ใช้เติม ProfileScreen
  /// ทุกครั้งที่เปิดหน้า เพื่อให้เห็นข้อมูลล่าสุดจาก server จริง ๆ ไม่ใช่ค่าที่ค้างในเครื่อง
  Future<Map<String, dynamic>> getMe() async =>
      (await _api.get('/users/me')) as Map<String, dynamic>;

  /// บันทึกข้อมูลโปรไฟล์ตัวเอง (ใช้คีย์เดียวกับ UpdateProfileDto ฝั่ง backend
  /// ได้ตรง ๆ: phone, lineId, fbLink, homeType, traits) คืนโปรไฟล์เต็มที่อัปเดตแล้ว
  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> fields) async =>
      (await _api.patch('/users/me', body: fields)) as Map<String, dynamic>;
}
