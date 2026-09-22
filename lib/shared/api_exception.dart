/// ห่อ error จาก backend ให้เป็นรูปแบบเดียวกันเสมอ
/// ตรงกับ { error: { code, message } } ที่ AllExceptionsFilter ฝั่ง NestJS ส่งมา
/// (ดู backend/api/src/common/http-exception.filter.ts)
class ApiException implements Exception {
  ApiException(this.statusCode, this.code, this.message);

  final int statusCode;
  final String code;
  final String message;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}
