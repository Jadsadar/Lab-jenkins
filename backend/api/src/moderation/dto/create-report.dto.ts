import { IsIn, IsOptional, IsUUID, MaxLength } from 'class-validator';

const REPORT_REASONS = [
  'fake_info',
  'spam',
  'inappropriate',
  'scam',
  'animal_abuse',
  'other',
] as const;

export type ReportReason = (typeof REPORT_REASONS)[number];

/**
 * ต้องระบุเป้าหมายพอดี 1 อย่าง (reportedPetId / reportedUserId / reportedMessageId)
 * — ไม่ตรวจ "exactly one" ในชั้น DTO เพราะ DB บังคับด้วย CHECK
 * reports_exactly_one_target อยู่แล้ว (ดู migration 006) และ AllExceptionsFilter
 * แปล constraint นี้เป็นข้อความไทยให้แล้ว การตรวจซ้ำในนี้จะเป็นการซ้ำซ้อนของกฎ
 */
export class CreateReportDto {
  @IsOptional()
  @IsUUID()
  reportedPetId?: string;

  @IsOptional()
  @IsUUID()
  reportedUserId?: string;

  @IsOptional()
  @IsUUID()
  reportedMessageId?: string;

  @IsIn(REPORT_REASONS)
  reason!: ReportReason;

  @IsOptional()
  @MaxLength(500)
  detail?: string;
}
