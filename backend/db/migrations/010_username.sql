-- =============================================================================
-- 010 — เพิ่ม username ให้ users
--
-- ที่มา: migration 002 สร้าง users ตาม entity ใน SKILL.md ตรง ๆ ซึ่งไม่มี
-- username (มีแค่ email) แต่หน้าจอ Flutter ที่ทีมเตรียมไว้จริง
-- (register_screen.dart, login_screen.dart) บังคับให้กรอก username ตอนสมัคร
-- และให้ล็อกอินด้วย "username หรือ email" ก็ได้ — ถ้าไม่มีคอลัมน์นี้
-- ธาต Auth module จะเชื่อมกับ frontend ไม่ได้ตั้งแต่หน้าแรก
--
-- ใช้ citext เหมือน email เพื่อกัน "Somchai" กับ "somchai" สมัครซ้ำกันได้
-- =============================================================================

BEGIN;

ALTER TABLE users ADD COLUMN username citext;

-- ห้ามมีช่องว่างหรือ @ (ตรงกับที่ RegisterScreen เช็กฝั่ง client อยู่แล้ว
-- แต่ต้องบังคับซ้ำที่ DB เพราะ client ไว้ใจไม่ได้)
ALTER TABLE users ADD CONSTRAINT users_username_shape
  CHECK (username IS NULL OR username ~ '^[^@[:space:]]+$');

ALTER TABLE users ALTER COLUMN username SET NOT NULL;

CREATE UNIQUE INDEX users_username_key ON users (username);

COMMENT ON COLUMN users.username IS
  'ใช้ล็อกอินแทน email ได้ — RegisterScreen บังคับกรอก, LoginScreen รับได้ทั้ง username/email';

COMMIT;
