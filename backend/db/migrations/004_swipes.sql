-- =============================================================================
-- 004 — การปัด (ถูกใจ / ไม่สนใจ)
--
-- ตารางในไฟล์นี้: likes, passes
--
-- SKILL.md แยก Like กับ Pass เป็นคนละ entity และย้ำว่า
-- "Chat กับ Likes ต้องแยกกันเด็ดขาด" — การกดถูกใจต้องไม่สร้างห้องแชท
-- จึงไม่มี foreign key หรือ trigger ใด ๆ จากไฟล์นี้ไปยัง conversations
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- likes — ผู้ใช้กดถูกใจสัตว์ตัวหนึ่ง
--
-- SKILL.md: "Like = (user ที่ปัด, pet ที่ถูกปัด) ผูกกับ pet ไม่ใช่ owner
--            เพราะคนอาจถูกใจแมวตัวหนึ่งของเจ้าของแต่ไม่สนใจตัวอื่น"
--
-- จึงไม่มีคอลัมน์ owner_id ในตารางนี้โดยตั้งใจ ถ้าอยากรู้ว่าใครเป็นเจ้าของ
-- ให้ join ผ่าน pets เอา
-- -----------------------------------------------------------------------------
CREATE TABLE likes (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid        NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- CASCADE ที่นี่ปลอดภัย เพราะ pets ใช้ soft delete
  -- แถวจะหายจริงเฉพาะตอนล้างข้อมูลถาวรจากงาน retention เท่านั้น
  pet_id     uuid        NOT NULL REFERENCES pets(id) ON DELETE CASCADE,

  created_at timestamptz NOT NULL DEFAULT now()
);

-- กดถูกใจตัวเดิมซ้ำไม่ได้ — บังคับที่ฐานข้อมูล ไม่ใช่เช็กในโค้ดแล้วค่อย insert
-- (เช็กก่อน insert มีช่องว่างให้ request 2 อันที่มาพร้อมกันผ่านไปได้ทั้งคู่)
CREATE UNIQUE INDEX likes_user_pet_key ON likes (user_id, pet_id);

-- หน้า Likes: ประวัติที่เราถูกใจ เรียงจากล่าสุด + keyset pagination
CREATE INDEX likes_user_created_idx ON likes (user_id, created_at DESC, id DESC);

-- "ใครถูกใจสัตว์ของฉันบ้าง" และใช้ตอนคำนวณ like_count ใหม่
CREATE INDEX likes_pet_idx ON likes (pet_id);


-- -----------------------------------------------------------------------------
-- passes — ผู้ใช้ปัดซ้าย (ไม่สนใจ)
--
-- เก็บไว้เพื่อกันการ์ดเด้งกลับมาซ้ำตาม checklist ของ SKILL.md
-- ("ไม่มีตัวที่ปัดไปแล้วเด้งซ้ำ")
--
-- แยกจาก likes แทนที่จะรวมเป็นตารางเดียวที่มีคอลัมน์ direction เพราะ:
--   1. SKILL.md กำหนด index บน like ไว้เฉพาะ ถ้ารวมกันจะต้องใส่ direction
--      ในทุก index ทำให้ index ใหญ่ขึ้นโดยไม่จำเป็น
--   2. passes เป็นข้อมูลชั่วคราวที่ลบทิ้งได้ (เช่นล้างของเก่าเกิน 90 วัน
--      เพื่อให้การ์ดเก่ากลับมาให้โอกาสอีกครั้ง) ส่วน likes เป็นข้อมูลถาวรของผู้ใช้
--   3. หน้า Likes ต้อง query เฉพาะ likes การแยกตารางทำให้ไม่มีทางดึงปนกัน
-- -----------------------------------------------------------------------------
CREATE TABLE passes (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  pet_id     uuid        NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX passes_user_pet_key ON passes (user_id, pet_id);

-- ใช้กับปุ่ม undo (หาตัวที่เพิ่งปัดล่าสุด) และงานล้างของเก่า
CREATE INDEX passes_user_created_idx ON passes (user_id, created_at DESC, id DESC);


-- -----------------------------------------------------------------------------
-- ห้ามปัดสัตว์ของตัวเอง
--
-- SKILL.md: "ห้ามปัดสัตว์ของตัวเอง — กรองออกตั้งแต่ชั้น query ไม่ใช่ซ่อนที่ฝั่ง UI"
--
-- query ของ deck จะกรองออกอยู่แล้ว แต่ endpoint POST /pets/:id/like
-- รับ id อะไรก็ได้ที่ client ส่งมา ถ้าลืมเช็กในโค้ดแม้แต่ที่เดียว
-- ก็จะปั่นยอดถูกใจสัตว์ตัวเองได้ trigger นี้ปิดช่องนั้นถาวร
--
-- ใช้ trigger แทน CHECK constraint เพราะ CHECK มองได้แค่คอลัมน์ในแถวเดียวกัน
-- ไม่สามารถไปอ่าน pets.owner_id ได้
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION reject_self_swipe()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  pet_owner uuid;
BEGIN
  SELECT owner_id INTO pet_owner FROM pets WHERE id = NEW.pet_id;

  IF pet_owner = NEW.user_id THEN
    RAISE EXCEPTION 'ห้ามปัดสัตว์เลี้ยงของตัวเอง (user=% pet=%)', NEW.user_id, NEW.pet_id
      USING ERRCODE = 'check_violation';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER likes_reject_self_swipe
  BEFORE INSERT ON likes
  FOR EACH ROW EXECUTE FUNCTION reject_self_swipe();

CREATE TRIGGER passes_reject_self_swipe
  BEFORE INSERT ON passes
  FOR EACH ROW EXECUTE FUNCTION reject_self_swipe();


-- -----------------------------------------------------------------------------
-- ดูแล pets.like_count ให้ตรงกับความจริงเสมอ
--
-- ถ้าให้ชั้น application เป็นคนบวกลบเอง จะมีวันที่ request ล้มกลางทาง
-- แล้วตัวเลขค้างผิดโดยไม่มีใครรู้ trigger ทำให้ตัวนับกับแถวจริง
-- อยู่ใน transaction เดียวกันเสมอ จะผิดพร้อมกันหรือถูกพร้อมกันเท่านั้น
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sync_pet_like_count()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE pets SET like_count = like_count + 1 WHERE id = NEW.pet_id;
    RETURN NEW;
  ELSE
    UPDATE pets SET like_count = GREATEST(like_count - 1, 0) WHERE id = OLD.pet_id;
    RETURN OLD;
  END IF;
END;
$$;

CREATE TRIGGER likes_sync_pet_like_count
  AFTER INSERT OR DELETE ON likes
  FOR EACH ROW EXECUTE FUNCTION sync_pet_like_count();

COMMIT;
