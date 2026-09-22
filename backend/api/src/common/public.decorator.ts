import { SetMetadata } from '@nestjs/common';

export const IS_PUBLIC_KEY = 'isPublic';

/**
 * ยกเว้น route นี้จาก JwtAuthGuard ที่เป็น global guard
 *
 * ใช้เฉพาะ register/login/refresh/health เท่านั้น — ตาม SKILL.md:
 * "ทุก endpoint ยกเว้น register/login/refresh ต้องผ่าน middleware ตรวจ auth
 *  เป็นค่าเริ่มต้น ถ้าลืมใส่ก็ต้องปิดไว้ก่อน ไม่ใช่เปิดไว้ก่อน"
 * การออกแบบ opt-out (ต้องแปะ @Public() ถึงจะเปิด) แทน opt-in ตรงตามหลักการนี้
 */
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
