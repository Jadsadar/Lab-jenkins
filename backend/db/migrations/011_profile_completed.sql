-- =============================================================================
-- 011 — ตัวบอกสถานะ "กรอกโปรไฟล์ครั้งแรกแล้วหรือยัง"
--
-- ที่มา: AuthGate ฝั่ง Flutter (main.dart) เช็ค user.displayName ว่าง เพื่อตัดสินใจ
-- ว่าจะพาไปหน้า CreateProfileScreen ก่อนเข้าแอปหรือไม่ — แต่ users.display_name
-- ใน migration 002 มี CHECK ห้ามว่าง (users_display_name_not_blank) ตั้งแต่ INSERT แรก
-- จึงใช้ "display_name ว่างไหม" เป็นตัวบอกสถานะแบบเดิมไม่ได้อีกต่อไป
--
-- แก้ด้วยการเพิ่มคอลัมน์แยกต่างหาก: ตอนสมัคร (POST /auth/register) จะตั้ง
-- display_name = username ไปก่อน (ให้มีค่าอะไรสักอย่างผ่าน CHECK) แล้วปล่อยให้
-- profile_completed_at เป็น NULL ไว้ — ฝั่ง client เช็คคอลัมน์นี้แทน
-- =============================================================================

BEGIN;

ALTER TABLE users ADD COLUMN profile_completed_at timestamptz;

COMMENT ON COLUMN users.profile_completed_at IS
  'NULL = ยังไม่เคยกรอกหน้าสร้างโปรไฟล์ครั้งแรก — client ใช้ตัดสินใจพาไปหน้า CreateProfileScreen';

COMMIT;
