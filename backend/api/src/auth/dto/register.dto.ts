import { IsEmail, IsString, Matches, MinLength } from 'class-validator';

export class RegisterDto {
  // ห้ามช่องว่างหรือ @ — ตรงกับ CHECK users_username_shape ใน migration 010
  @IsString()
  @MinLength(3)
  @Matches(/^[^@\s]+$/, { message: 'ชื่อผู้ใช้ห้ามมีช่องว่างหรือเครื่องหมาย @' })
  username!: string;

  @IsEmail({}, { message: 'รูปแบบอีเมลไม่ถูกต้อง' })
  email!: string;

  @IsString()
  @MinLength(8)
  password!: string;
}
