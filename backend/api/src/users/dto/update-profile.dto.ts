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

  @IsOptional()
  @IsUrl()
  profileImageUrl?: string;

  // slug ของแท็ก (ต้องตรงกับ traits.slug / lib/utils/pet_tags.dart)
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  traits?: string[];
}
