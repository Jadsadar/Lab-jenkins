/// ตัวช่วยแยกแยะว่าไฟล์สื่อของรีลเป็น "วิดีโอ" หรือ "ภาพนิ่ง"
/// และมาจาก assets ในเครื่องหรือจาก URL บนอินเทอร์เน็ต
const List<String> _videoExtensions = ['.mp4', '.mov', '.m4v', '.webm'];

/// เป็นไฟล์วิดีโอหรือไม่ (ดูจากนามสกุลไฟล์)
bool isVideoSource(String? source) {
  final value = source?.trim().toLowerCase();
  if (value == null || value.isEmpty) return false;
  // ตัด query string ออกก่อน เช่น .mp4?token=123
  final path = value.split('?').first;
  return _videoExtensions.any(path.endsWith);
}

/// เป็นไฟล์ที่ฝังมากับแอป (assets/...) หรือไม่
bool isAssetSource(String? source) {
  final value = source?.trim();
  if (value == null || value.isEmpty) return false;
  return value.startsWith('assets/');
}

/// รีลนี้มีสื่อให้แสดงหรือไม่ (มีค่าและไม่ใช่ช่องว่าง)
bool hasReelMedia(Map<String, dynamic> dog) {
  final reel = dog['reelUrl'];
  return reel != null && reel.toString().trim().isNotEmpty;
}
