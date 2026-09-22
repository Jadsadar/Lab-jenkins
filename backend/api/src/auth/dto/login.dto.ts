import { IsString, MinLength } from 'class-validator';

export class LoginDto {
  // รับได้ทั้ง username หรือ email — ฝั่ง service เป็นคนแยกด้วยการเช็คว่ามี '@' ไหม
  @IsString()
  @MinLength(1)
  identifier!: string;

  @IsString()
  @MinLength(1)
  password!: string;
}
