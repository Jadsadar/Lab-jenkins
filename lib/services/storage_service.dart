import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// อัปโหลดรูปภาพทั่วไป (ที่ไม่ใช่รูปโปรไฟล์ผู้ใช้) ขึ้น Firebase Storage
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// อัปโหลดรูปโปรไฟล์สัตว์เลี้ยง คืนค่า download URL ของรูปที่อัปโหลดสำเร็จ
  Future<String> uploadPetImage(Uint8List bytes,
      {String contentType = 'image/jpeg'}) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final ref = _storage.ref('pet_images/$id.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }
}
