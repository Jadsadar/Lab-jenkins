-- =============================================================================
-- 001 — Extension, ชนิดข้อมูล และฟังก์ชันที่ใช้ร่วมกันทั้งระบบ
-- =============================================================================

BEGIN;

-- citext = ข้อความที่เปรียบเทียบแบบไม่สนตัวพิมพ์เล็กใหญ่
-- ใช้กับ email เพื่อไม่ให้ "Somchai@mail.com" กับ "somchai@mail.com"
-- สมัครเป็นคนละบัญชีได้ ซึ่งเป็นช่องทางสวมรอยคลาสสิก
CREATE EXTENSION IF NOT EXISTS citext;

-- pg_trgm = index สำหรับค้นหาข้อความบางส่วน (LIKE '%คำ%')
-- เตรียมไว้ให้ช่องค้นหาชื่อสัตว์/สายพันธุ์ในอนาคต
CREATE EXTENSION IF NOT EXISTS pg_trgm;


-- -----------------------------------------------------------------------------
-- ชนิดข้อมูลแบบ enum
--
-- ใช้ enum จริงของ Postgres แทน varchar + CHECK เพราะ:
--   1. กินพื้นที่ 4 ไบต์ ไม่ใช่ความยาวข้อความ
--   2. พิมพ์ผิดจะ error ตั้งแต่ตอน INSERT ไม่ใช่ไปเงียบ ๆ อยู่ในฐาน
--   3. ORM ฝั่ง TypeScript generate union type ให้ได้ตรง ๆ
--
-- ข้อควรระวัง: เพิ่มค่าใหม่ทำได้ (ALTER TYPE ... ADD VALUE) แต่ "ลบ" ค่าทำไม่ได้
-- จึงใช้เฉพาะกับชุดค่าที่นิ่งแล้วเท่านั้น
-- -----------------------------------------------------------------------------

-- สถานะประกาศ ตาม SKILL.md: available | pending | adopted
--   available = เปิดรับ แสดงใน deck
--   pending   = มีคนติดต่อมาแล้วกำลังคุยกันอยู่ ไม่แสดงใน deck แต่ยังไม่จบ
--   adopted   = ได้บ้านแล้ว หลุดจาก deck แต่ยังอยู่บนโปรไฟล์พร้อมป้ายสถานะ
CREATE TYPE pet_status AS ENUM ('available', 'pending', 'adopted');

CREATE TYPE pet_sex AS ENUM ('male', 'female', 'unknown');

CREATE TYPE pet_size AS ENUM ('small', 'medium', 'large');

CREATE TYPE pet_species AS ENUM ('dog', 'cat', 'rabbit', 'bird', 'other');

-- สถานะห้องแชท
--   active = คุยกันได้ปกติ
--   closed = ปิดแล้ว อ่านย้อนหลังได้แต่ส่งข้อความใหม่ไม่ได้
CREATE TYPE conversation_status AS ENUM ('active', 'closed');

-- เหตุผลที่ห้องแชทถูกปิด — เก็บไว้เพื่อขึ้นข้อความอธิบายให้ผู้ใช้เข้าใจ
-- ว่าทำไมพิมพ์ต่อไม่ได้ แทนที่จะให้ช่องพิมพ์หายไปเฉย ๆ
CREATE TYPE conversation_closed_reason AS ENUM (
  'pet_adopted',   -- เจ้าของเปลี่ยนสถานะเป็น "ได้บ้านแล้ว"
  'pet_deleted',   -- ประกาศถูกลบ
  'blocked',       -- ฝ่ายใดฝ่ายหนึ่งกดบล็อก
  'user_deleted',  -- คู่สนทนาลบบัญชี
  'moderation'     -- แอดมินปิดจากการรายงาน
);

CREATE TYPE report_reason AS ENUM (
  'fake_info',
  'spam',
  'inappropriate',
  'scam',
  'animal_abuse',
  'other'
);

CREATE TYPE report_status AS ENUM ('pending', 'reviewing', 'actioned', 'dismissed');

CREATE TYPE device_platform AS ENUM ('ios', 'android', 'web');

-- ตอนนี้ลงประกาศได้แค่รูป แต่แผนถัดไปคือรองรับวิดีโอสั้น
-- ใส่ enum ไว้ตั้งแต่ตอนนี้ (แถวทุกแถวจะเป็น 'photo' ก่อน) เพื่อไม่ต้อง migrate
-- ตาราง pet_media ที่มีข้อมูลจริงอยู่แล้วในวันที่เพิ่มวิดีโอ
CREATE TYPE pet_media_type AS ENUM ('photo', 'video');

-- ภูมิภาคมาตรฐาน 6 ภาคของไทย ใช้จัดกลุ่มจังหวัดสำหรับค้นหาแบบ "ใกล้ก่อนแล้วค่อยขยาย"
CREATE TYPE thai_region AS ENUM (
  'central', 'north', 'northeast', 'east', 'west', 'south'
);


-- -----------------------------------------------------------------------------
-- ฟังก์ชันอัปเดต updated_at อัตโนมัติ
--
-- ถ้าปล่อยให้ชั้น application เป็นคนเซ็ต จะมีบาง query ที่ลืม
-- แล้ว updated_at จะโกหกโดยไม่มีใครรู้ตัว
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

COMMIT;
