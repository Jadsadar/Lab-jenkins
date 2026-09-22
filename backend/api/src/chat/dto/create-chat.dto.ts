import { IsString, IsUUID, MaxLength, MinLength } from 'class-validator';

// SKILL.md: "ห้องแชทเกิดตอนผู้ใช้กดส่งข้อความแรกเท่านั้น" — DB บังคับด้วย deferred
// constraint trigger (conversations_require_first_message) จึงไม่มี endpoint
// "สร้างห้องเปล่า" แยกต่างหาก ต้องส่งข้อความแรกมาพร้อมกันเสมอ
export class CreateChatDto {
  @IsUUID()
  petId!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(2000)
  message!: string;
}
