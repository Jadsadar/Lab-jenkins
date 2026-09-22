import 'dart:typed_data';

import '../shared/api_client.dart';

/// อัปโหลดรูปภาพสัตว์เลี้ยง (ไม่ใช่รูปโปรไฟล์ผู้ใช้ — อันนั้นอยู่ใน AuthService)
/// ผ่าน POST /media/upload ซึ่งเก็บไฟล์ลง MinIO แล้วคืน URL สาธารณะกลับมา
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final ApiClient _api = ApiClient.instance;

  /// อัปโหลดรูปสัตว์เลี้ยง คืนค่า URL ของรูปที่อัปโหลดสำเร็จ
  Future<String> uploadPetImage(Uint8List bytes, {String contentType = 'image/jpeg'}) async {
    final res = await _api.uploadFile(
      '/media/upload',
      bytes: bytes,
      filename: 'pet.${contentType.split('/').last}',
      contentType: contentType,
    ) as Map<String, dynamic>;
    return res['url'] as String;
  }
}
