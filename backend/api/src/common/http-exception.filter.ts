import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import type { Response } from 'express';

/**
 * รวม error ทุกชนิดให้ออกมาเป็นรูปแบบเดียวกันเสมอ: { error: { code, message } }
 *
 * ครอบคลุมกรณีที่ business rule ถูกบังคับใน Postgres (constraint/trigger)
 * แล้วโผล่ขึ้นมาเป็น DatabaseError ธรรมดา — ถ้าไม่แปลตรงนี้ ผู้ใช้จะเห็น
 * "internal server error" ทั้งที่จริง ๆ คือ "ห้ามปัดสัตว์ของตัวเอง" ซึ่งมีข้อความ
 * ที่อ่านได้อยู่แล้วใน constraint name (ดู backend/db/migrations)
 */
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger('ExceptionFilter');

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const body = exception.getResponse();
      // AppException ส่ง { code, message } มาเป็น response body อยู่แล้ว
      if (typeof body === 'object' && body !== null && 'code' in body) {
        response.status(status).json({ error: body });
        return;
      }
      // HttpException มาตรฐานของ Nest (เช่นจาก ValidationPipe) — message อาจเป็น array
      const message = Array.isArray((body as any)?.message)
        ? (body as any).message.join(', ')
        : ((body as any)?.message ?? exception.message);
      response.status(status).json({
        error: { code: this.codeForStatus(status), message },
      });
      return;
    }

    // pg driver โยน error object ที่มี .code เป็นรหัส SQLSTATE เสมอเมื่อ DB ปฏิเสธ
    const pgError = exception as { code?: string; message?: string; constraint?: string };
    if (typeof pgError?.code === 'string') {
      const mapped = this.mapPostgresError(pgError);
      if (mapped) {
        response.status(mapped.status).json({
          error: { code: mapped.code, message: mapped.message },
        });
        return;
      }
    }

    // เหลือแต่ error ที่ไม่คาดคิดจริง ๆ — log ไว้เต็ม ๆ แต่ไม่โชว์ stack ให้ client เห็น
    this.logger.error(exception instanceof Error ? exception.stack : exception);
    response.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
      error: { code: 'INTERNAL', message: 'เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่อีกครั้ง' },
    });
  }

  private codeForStatus(status: number): string {
    switch (status) {
      case HttpStatus.BAD_REQUEST:
        return 'VALIDATION_ERROR';
      case HttpStatus.UNAUTHORIZED:
        return 'UNAUTHORIZED';
      case HttpStatus.FORBIDDEN:
        return 'FORBIDDEN';
      case HttpStatus.NOT_FOUND:
        return 'NOT_FOUND';
      case HttpStatus.CONFLICT:
        return 'CONFLICT';
      default:
        return 'ERROR';
    }
  }

  private mapPostgresError(
    err: { code?: string; message?: string; constraint?: string },
  ): { status: number; code: string; message: string } | null {
    switch (err.code) {
      case '23505': // unique_violation
        return {
          status: HttpStatus.CONFLICT,
          code: 'DUPLICATE',
          message: 'ข้อมูลนี้ถูกใช้ไปแล้ว (ซ้ำกับที่มีอยู่ในระบบ)',
        };
      case '23503': // foreign_key_violation
        return {
          status: HttpStatus.BAD_REQUEST,
          code: 'INVALID_REFERENCE',
          message: 'ข้อมูลอ้างอิงไม่ถูกต้อง (เช่น จังหวัดหรือแท็กที่ไม่มีอยู่จริง)',
        };
      case '23514': // check_violation — ส่วนใหญ่คือกฎธุรกิจที่ฝังไว้ใน DB
        // trigger ที่เขียนเองทุกตัว (reject_self_swipe, on_message_inserted ฯลฯ)
        // RAISE EXCEPTION ด้วยข้อความไทยที่อ่านรู้เรื่องอยู่แล้ว ใช้ตรง ๆ ได้เลย
        // ถ้าไม่มี constraint name แปลว่ามาจาก RAISE EXCEPTION ไม่ใช่ CHECK ธรรมดา
        return {
          status: HttpStatus.BAD_REQUEST,
          code: 'BUSINESS_RULE_VIOLATION',
          message:
            this.friendlyConstraintMessage(err.constraint) ??
            (!err.constraint && err.message ? err.message : 'คำขอนี้ขัดกับกฎของระบบ'),
        };
      default:
        return null;
    }
  }

  // แปล constraint name ที่ตั้งชื่อไว้อย่างมีความหมายใน migration ให้เป็นข้อความไทย
  // ดู backend/db/README.md หัวข้อ "กฎที่ฐานข้อมูลบังคับให้เอง" สำหรับรายการเต็ม
  private friendlyConstraintMessage(constraint?: string): string | null {
    const map: Record<string, string> = {
      likes_reject_self_swipe: 'ปัดสัตว์เลี้ยงของตัวเองไม่ได้',
      passes_reject_self_swipe: 'ปัดสัตว์เลี้ยงของตัวเองไม่ได้',
      conversations_two_distinct_people: 'ทักหาตัวเองไม่ได้',
      pets_adopted_at_consistent: 'สถานะไม่ถูกต้อง',
      blocks_no_self: 'บล็อกตัวเองไม่ได้',
      reports_exactly_one_target: 'ต้องระบุสิ่งที่จะรายงานให้ครบถ้วน',
      reports_not_self: 'รายงานตัวเองไม่ได้',
      messages_body_length: 'ข้อความยาวเกินไป (สูงสุด 2000 ตัวอักษร)',
      messages_body_not_blank: 'ข้อความห้ามว่างเปล่า',
      users_username_shape: 'ชื่อผู้ใช้ห้ามมีช่องว่างหรือเครื่องหมาย @',
    };
    return constraint ? (map[constraint] ?? null) : null;
  }
}
