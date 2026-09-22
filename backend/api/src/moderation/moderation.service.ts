import { Inject, Injectable } from '@nestjs/common';
import type { Pool } from 'pg';
import { PG_POOL } from '../database/database.module.js';
import type { CreateReportDto } from './dto/create-report.dto.js';
import type { CreateBlockDto } from './dto/create-block.dto.js';

@Injectable()
export class ModerationService {
  constructor(@Inject(PG_POOL) private readonly pool: Pool) {}

  /**
   * "เป้าหมายพอดี 1 อย่าง" / "รายงานตัวเองไม่ได้" / "รายงานซ้ำเป้าหมายเดิมไม่ได้"
   * ถูกบังคับด้วย CHECK + unique partial index ใน migration 006 อยู่แล้ว —
   * ถ้าผิดกฎ pg จะโยน error ที่ AllExceptionsFilter แปลเป็นข้อความไทยให้เอง
   */
  async createReport(userId: string, dto: CreateReportDto) {
    const result = await this.pool.query<{ id: string }>(
      `INSERT INTO reports (reporter_id, reported_pet_id, reported_user_id, reported_message_id, reason, detail)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id`,
      [
        userId,
        dto.reportedPetId ?? null,
        dto.reportedUserId ?? null,
        dto.reportedMessageId ?? null,
        dto.reason,
        dto.detail ?? null,
      ],
    );
    return { id: result.rows[0].id };
  }

  /**
   * บล็อกซ้ำ (กด 2 ครั้ง) ถือเป็นการ no-op ไม่ใช่ error — ผลลัพธ์ปลายทาง
   * เหมือนกันคือ "บล็อกอยู่" ไม่มีเหตุผลให้ผู้ใช้เห็น error ตอนกดปุ่มซ้ำ
   * (trigger blocks_close_conversations ยังทำงานปกติตอน insert ครั้งแรกเท่านั้น)
   */
  async createBlock(userId: string, dto: CreateBlockDto) {
    await this.pool.query(
      `INSERT INTO blocks (blocker_id, blocked_id, reason)
       VALUES ($1, $2, $3)
       ON CONFLICT (blocker_id, blocked_id) DO NOTHING`,
      [userId, dto.blockedUserId, dto.reason ?? null],
    );
    return { success: true };
  }

  async deleteBlock(userId: string, blockedUserId: string) {
    await this.pool.query(
      `DELETE FROM blocks WHERE blocker_id = $1 AND blocked_id = $2`,
      [userId, blockedUserId],
    );
    return { success: true };
  }
}
