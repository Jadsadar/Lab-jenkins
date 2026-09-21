-- =============================================================================
-- 002 — ผู้ใช้และการยืนยันตัวตน
--
-- ตารางในไฟล์นี้: users, refresh_tokens, password_reset_tokens, device_tokens
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- users — บัญชีผู้ใช้ 1 คน
--
-- SKILL.md ระบุว่าไม่มีการแบ่งบทบาทเป็น "ผู้ลงประกาศ" กับ "ผู้รับเลี้ยง"
-- ทุกคนคือ user คนเดียวกันที่ลงประกาศก็ได้ ปัดก็ได้
-- จึง **ไม่มี** คอลัมน์ role ในตารางนี้โดยตั้งใจ
-- -----------------------------------------------------------------------------
CREATE TABLE users (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),

  -- citext ทำให้ unique constraint ครอบคลุมทุกรูปแบบตัวพิมพ์โดยอัตโนมัติ
  email           citext      NOT NULL,

  -- แฮชจาก argon2id หรือ bcrypt เท่านั้น ห้ามเก็บรหัสผ่านดิบหรือ MD5/SHA ล้วน
  -- ความยาว 255 รองรับได้ทั้งสองอัลกอริทึม (argon2id ยาวราว 97 ตัวอักษร)
  password_hash   varchar(255) NOT NULL,

  display_name    varchar(50)  NOT NULL,
  avatar_url      text,
  bio             varchar(500),

  -- ที่อยู่แบบหยาบ (ชื่อจังหวัด) ใช้กรอง deck ให้เจอสัตว์ใกล้ตัว
  location        varchar(100),

  -- ปิดกั้นบัญชีจากฝั่งแอดมิน เช่นโดนรายงานซ้ำ ๆ จนต้องระงับ
  is_suspended    boolean     NOT NULL DEFAULT false,
  suspended_until timestamptz,

  -- สิทธิ์ดูรายงาน ตั้งค่าได้จากฝั่งฐานข้อมูลเท่านั้น ไม่มี endpoint ให้ยกระดับตัวเอง
  is_admin        boolean     NOT NULL DEFAULT false,

  email_verified_at timestamptz,
  last_login_at     timestamptz,

  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),

  -- soft delete: ลบบัญชีจริงไม่ได้เพราะจะทำให้ประกาศ ข้อความ และห้องแชท
  -- ของ "อีกฝ่าย" หายตามไปด้วย ซึ่งไม่ยุติธรรมกับคู่สนทนา
  deleted_at      timestamptz,

  CONSTRAINT users_display_name_not_blank CHECK (length(btrim(display_name)) > 0),
  CONSTRAINT users_email_shape CHECK (email ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$')
);

-- อีเมลห้ามซ้ำ "ตลอดกาล" แม้บัญชีจะถูก soft delete ไปแล้ว
-- เพื่อไม่ให้มีใครสมัครทับอีเมลของคนที่เพิ่งลบบัญชีแล้วเข้าถึงประวัติแชทเดิม
CREATE UNIQUE INDEX users_email_key ON users (email);

CREATE TRIGGER users_set_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE users IS 'บัญชีผู้ใช้ — ทุกคนลงประกาศและปัดได้เท่ากัน ไม่มีการแบ่ง role';
COMMENT ON COLUMN users.deleted_at IS 'soft delete — ทุก query ต้องกรอง WHERE deleted_at IS NULL';


-- -----------------------------------------------------------------------------
-- refresh_tokens — รองรับ refresh token ที่หมุนเวียนและเพิกถอนได้
--
-- SKILL.md: "refresh token อายุยาว (30 วัน) ที่หมุนเวียนทุกครั้งที่ใช้และเพิกถอนได้"
--
-- ทำไมต้องมีตาราง ไม่ใช่แค่ JWT เปล่า ๆ:
-- JWT ที่ออกไปแล้วเพิกถอนไม่ได้โดยธรรมชาติ ถ้าไม่มีรายการฝั่ง server
-- token ที่หลุดออกไปจะใช้ได้จนกว่าจะหมดอายุ 30 วัน โดยที่เจ้าของบัญชีทำอะไรไม่ได้เลย
--
-- แนวคิด "family" (สายของ token):
-- ทุกครั้งที่ refresh จะออก token ใหม่และทำเครื่องหมายอันเก่าว่าถูกใช้แล้ว
-- ถ้ามีใครเอา token "อันเก่าที่ถูกใช้ไปแล้ว" มาใช้ซ้ำ แปลว่ามีสำเนาหลุดออกไป
-- ระบบจะเพิกถอนทั้งสายทันที บังคับให้ทั้งขโมยและเจ้าของตัวจริงต้องล็อกอินใหม่
-- -----------------------------------------------------------------------------
CREATE TABLE refresh_tokens (
  id             uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        uuid        NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- เก็บ "แฮช" ของ token ไม่ใช่ตัว token
  -- ถ้าฐานข้อมูลหลุด คนที่ได้ไปจะสวมรอยไม่ได้ เหมือนหลักการเดียวกับรหัสผ่าน
  token_hash     char(64)    NOT NULL,      -- sha256 เขียนเป็น hex

  -- token ทุกอันที่สืบทอดกันมาจากการล็อกอินครั้งเดียวกันจะมี family_id เดียวกัน
  family_id      uuid        NOT NULL,

  -- ชี้ไปยัง token ที่มาแทนที่อันนี้ ใช้ไล่ย้อนสายตอนสืบสวน
  replaced_by_id uuid        REFERENCES refresh_tokens(id) ON DELETE SET NULL,

  expires_at     timestamptz NOT NULL,
  used_at        timestamptz,               -- เวลาที่ถูกนำไป refresh
  revoked_at     timestamptz,
  revoked_reason varchar(50),               -- 'rotated' | 'logout' | 'reuse_detected' | 'password_changed'

  -- ข้อมูลเครื่องที่ขอ token ไว้ให้ผู้ใช้ดูว่า "มีอุปกรณ์ไหนล็อกอินอยู่บ้าง"
  user_agent     varchar(255),
  ip_address     inet,

  created_at     timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX refresh_tokens_token_hash_key ON refresh_tokens (token_hash);
CREATE INDEX refresh_tokens_user_id_idx           ON refresh_tokens (user_id);
CREATE INDEX refresh_tokens_family_id_idx         ON refresh_tokens (family_id);
-- ใช้โดยงานกวาดล้าง token หมดอายุที่รันเป็นรอบ (BullMQ repeatable job)
CREATE INDEX refresh_tokens_expires_at_idx        ON refresh_tokens (expires_at)
  WHERE revoked_at IS NULL;

COMMENT ON COLUMN refresh_tokens.family_id IS
  'token ทั้งสายจากการล็อกอินครั้งเดียวกัน — ถ้าเจอการใช้ซ้ำให้เพิกถอนทั้ง family';


-- -----------------------------------------------------------------------------
-- password_reset_tokens — รองรับหน้า "ลืมรหัสผ่าน" (หน้าจอกลุ่มที่ 1 ใน SKILL.md)
-- -----------------------------------------------------------------------------
CREATE TABLE password_reset_tokens (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash char(64)    NOT NULL,
  expires_at timestamptz NOT NULL,
  used_at    timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX password_reset_tokens_token_hash_key ON password_reset_tokens (token_hash);
-- ใช้เช็กว่าผู้ใช้กดขอลิงก์รีเซ็ตรัว ๆ หรือเปล่า (rate limit)
CREATE INDEX password_reset_tokens_user_created_idx
  ON password_reset_tokens (user_id, created_at DESC);


-- -----------------------------------------------------------------------------
-- device_tokens — FCM token สำหรับ push notification
--
-- 1 คนมีได้หลายเครื่อง จึงต้องเป็นตารางแยก ไม่ใช่คอลัมน์เดียวบน users
--
-- token เดียวกันย้ายเจ้าของได้จริง (ผู้ใช้ A ออกจากระบบ ผู้ใช้ B ล็อกอินบนเครื่องเดิม)
-- unique อยู่ที่ token อย่างเดียว ไม่ใช่ (user_id, token) — ไม่งั้น A จะยังได้รับ
-- แจ้งเตือนของตัวเองบนเครื่องที่ B ใช้อยู่
-- -----------------------------------------------------------------------------
CREATE TABLE device_tokens (
  id           uuid            PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token        varchar(255)    NOT NULL,
  platform     device_platform NOT NULL,
  -- ใช้ตัดสินว่าควรลบ token ที่ตายแล้วทิ้งเมื่อไหร่ (เช่นไม่ได้ใช้เกิน 60 วัน)
  last_seen_at timestamptz     NOT NULL DEFAULT now(),
  created_at   timestamptz     NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX device_tokens_token_key    ON device_tokens (token);
CREATE INDEX        device_tokens_user_id_idx  ON device_tokens (user_id);
CREATE INDEX        device_tokens_last_seen_idx ON device_tokens (last_seen_at);

COMMIT;
