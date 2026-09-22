import { HttpException, HttpStatus } from '@nestjs/common';

/**
 * exception มาตรฐานของทั้งระบบ — ทุก error ที่ตั้งใจโยนควรใช้ตัวนี้
 * เพื่อให้ response shape ({ error: { code, message } }) เหมือนกันหมด
 * ตาม SKILL.md: "validate input ทุกตัวที่ขอบ API และคืน error เป็นรูปแบบเดียวกันทั้งระบบ"
 */
export class AppException extends HttpException {
  constructor(
    public readonly code: string,
    message: string,
    status: HttpStatus = HttpStatus.BAD_REQUEST,
  ) {
    super({ code, message }, status);
  }

  static unauthorized(message = 'กรุณาเข้าสู่ระบบก่อน') {
    return new AppException('UNAUTHORIZED', message, HttpStatus.UNAUTHORIZED);
  }

  static forbidden(message = 'ไม่มีสิทธิ์ทำรายการนี้') {
    return new AppException('FORBIDDEN', message, HttpStatus.FORBIDDEN);
  }

  static notFound(message = 'ไม่พบข้อมูลที่ต้องการ') {
    return new AppException('NOT_FOUND', message, HttpStatus.NOT_FOUND);
  }

  static conflict(message: string) {
    return new AppException('CONFLICT', message, HttpStatus.CONFLICT);
  }
}
