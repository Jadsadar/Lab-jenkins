import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// เก็บ access/refresh token ใน secure storage ของเครื่อง (Keychain/Keystore/
/// เข้ารหัสใน IndexedDB บนเว็บ) ไม่ใช่ SharedPreferences ธรรมดา เพราะ token
/// พวกนี้คือกุญแจเข้าบัญชีโดยตรง หลุดแล้วสวมรอยได้ทันที
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const _accessKey = 'petpaws_access_token';
  static const _refreshKey = 'petpaws_refresh_token';

  final _storage = const FlutterSecureStorage();

  /// ⚠️ ต้องเขียนทีละตัวตามลำดับ ห้ามใช้ Future.wait เขียนพร้อมกันเด็ดขาด
  ///
  /// บนเว็บ flutter_secure_storage เข้ารหัสค่าด้วย AES key ที่เก็บใน localStorage
  /// และจะสร้าง key ให้อัตโนมัติตอนเขียนครั้งแรกถ้ายังไม่มี — แต่โค้ดของมันเช็ค
  /// containsKey() แล้วเว้น await ไปอีก 2 จังหวะ (generateKey/exportKey) ก่อนจะ
  /// เขียน key ลง storage จริง เป็น check-then-act race เต็ม ๆ
  ///
  /// ถ้าเขียนพร้อมกัน 2 ค่า ทั้งคู่จะเห็นว่า "ยังไม่มี key" แล้วต่างคนต่างสร้าง key
  /// คนละดอก ตัวที่เขียนทีหลังทับตัวแรก → ค่าที่เข้ารหัสด้วย key ที่ถูกทับจะถอด
  /// ไม่ออกตลอดไป ขึ้น OperationError ตอนอ่าน (อาการ: ล็อกอินผ่าน แต่พอเรียก API
  /// ที่ต้องใช้ token กลับเด้ง "บันทึกไม่สำเร็จ")
  Future<void> save({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<String?> readAccessToken() => _read(_accessKey);
  Future<String?> readRefreshToken() => _read(_refreshKey);

  /// ถ้าถอดรหัสไม่ออก (เช่นมีข้อมูลเสียจาก race ข้างบนค้างอยู่ในเครื่องแล้ว) ให้
  /// ล้างทิ้งแล้วถือว่าไม่มี token — ผู้ใช้จะถูกพากลับไปล็อกอินใหม่แล้วเก็บ token
  /// ชุดใหม่อย่างถูกต้อง ดีกว่าปล่อยให้ค้างพังถาวรจนต้องไปล้าง site data เอง
  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> updateAccessToken(String accessToken) =>
      _storage.write(key: _accessKey, value: accessToken);

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
