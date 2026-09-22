import { IsArray, IsOptional, IsString, IsUrl, MaxLength } from 'class-validator';

// ชื่อ field ตรงกับ currentUserProfile ฝั่ง Flutter เป๊ะ ๆ (name, phone, lineId, fbLink,
// homeType, profileImageUrl, traits, province) เพื่อให้ service ฝั่ง Flutter ไม่ต้อง
// แปลงชื่อ key ไปมา — แปลงแค่ค่าบางตัว (เช่น homeType label<->enum) ที่ server เท่านั้น
export class UpdateProfileDto {
  @IsOptional()
  @IsString()
  @MaxLength(50)
  name?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  province?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  bio?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  phone?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  lineId?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  fbLink?: string;

  @IsOptional()
  @IsString()
  homeType?: string;

  // require_tld: false เพราะ URL ที่ media module ออกให้ตอน dev ชี้ไปที่ MinIO
  // (http://localhost:9000/...) ซึ่ง host ไม่มี TLD — ค่าเริ่มต้นของ @IsUrl() จะ
  // ปฏิเสธทิ้งทั้งที่เป็น URL ที่ระบบเราสร้างเองกับมือ ทำให้อัปรูปโปรไฟล์ไม่ผ่าน
  // ตลอดใน dev (อัปขึ้น storage สำเร็จ แต่บันทึกลงโปรไฟล์ไม่ได้)
  @IsOptional()
  @IsUrl({ require_tld: false })
  profileImageUrl?: string;

  // slug ของแท็ก (ต้องตรงกับ traits.slug / lib/utils/pet_tags.dart)
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  traits?: string[];
}
