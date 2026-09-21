-- =============================================================================
-- 005 — ห้องแชทและข้อความ
--
-- ตารางในไฟล์นี้: conversations, messages
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- conversations — ห้องแชทระหว่างผู้สนใจกับเจ้าของ เกี่ยวกับสัตว์ 1 ตัว
--
-- SKILL.md: "Conversation เกิดระหว่าง user 2 คน และอ้างอิง pet ที่เป็นต้นเรื่อง
--            (pet_id) เพื่อให้เจ้าของรู้ว่าทักมาเรื่องสัตว์ตัวไหน"
--
-- ห้องผูกกับ "สัตว์" ไม่ใช่แค่คู่สนทนา คนคนเดียวกันทักเรื่องสัตว์ 2 ตัว
-- ของเจ้าของคนเดียวกัน = 2 ห้องแยกกัน
-- -----------------------------------------------------------------------------
CREATE TABLE conversations (
  id           uuid NOT NULL DEFAULT gen_random_uuid(),

  pet_id       uuid NOT NULL,

  -- ฝ่ายที่ทักมาก่อน
  initiator_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,

  -- เจ้าของสัตว์ ทำซ้ำมาจาก pets.owner_id
  --
  -- ทำไมต้องทำซ้ำ: SKILL.md บังคับ index conversation(owner_id, last_message_at desc)
  -- ถ้าไม่มีคอลัมน์นี้ การดึงกล่องข้อความต้อง join pets ทุกครั้ง
  -- ซึ่งทำให้ index ตามที่สเปคกำหนดสร้างไม่ได้
  owner_id     uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,

  status        conversation_status NOT NULL DEFAULT 'active',
  closed_at     timestamptz,
  closed_reason conversation_closed_reason,

  -- ข้อมูลข้อความล่าสุด ทำซ้ำไว้เพื่อให้หน้ารายการห้องแชทดึงได้ใน query เดียว
  -- ไม่ต้องยิง subquery หาข้อความล่าสุดของแต่ละห้อง (ซึ่งคือ N+1 ชัด ๆ)
  --
  -- NOT NULL โดยตั้งใจ: ห้องที่ไม่มีข้อความเลยต้องไม่มีอยู่จริง
  last_message_at         timestamptz NOT NULL DEFAULT now(),
  last_message_preview    varchar(120),
  last_message_sender_id  uuid REFERENCES users(id) ON DELETE SET NULL,

  -- จำนวนข้อความที่ยังไม่ได้อ่านของแต่ละฝ่าย ดูแลโดย trigger
  --
  -- ทำไมไม่ COUNT(*) เอาตอน query: "GET /conversations รายการห้อง + unread count"
  -- ถ้านับสดจะกลายเป็น 1 query ต่อ 1 ห้อง = N+1 ที่ checklist ห้ามไว้
  initiator_unread_count int NOT NULL DEFAULT 0,
  owner_unread_count     int NOT NULL DEFAULT 0,

  initiator_last_read_at timestamptz,
  owner_last_read_at     timestamptz,

  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT conversations_pkey PRIMARY KEY (id),

  -- คู่สนทนาต้องเป็นคนละคน — ห้ามทักหาตัวเอง
  CONSTRAINT conversations_two_distinct_people CHECK (initiator_id <> owner_id),

  CONSTRAINT conversations_unread_non_negative
    CHECK (initiator_unread_count >= 0 AND owner_unread_count >= 0),

  CONSTRAINT conversations_closed_consistent CHECK (
    (status = 'closed' AND closed_at IS NOT NULL AND closed_reason IS NOT NULL) OR
    (status = 'active' AND closed_at IS NULL AND closed_reason IS NULL)
  ),

  -- กุญแจสำคัญ: อ้างอิงทั้งคู่ (pet_id, owner_id) ไปยัง pets พร้อมกัน
  --
  -- ผลคือ owner_id ที่ทำซ้ำไว้ **เป็นไปไม่ได้เลย** ที่จะไม่ตรงกับเจ้าของจริง
  -- ของสัตว์ตัวนั้น ต่อให้โค้ดฝั่ง application เขียนผิด ฐานข้อมูลจะปฏิเสธเอง
  --
  -- นี่คือทางแก้ปัญหาคลาสสิกของการ denormalize: ได้ความเร็วโดยไม่เสี่ยงข้อมูลเพี้ยน
  CONSTRAINT conversations_pet_owner_fk
    FOREIGN KEY (pet_id, owner_id) REFERENCES pets(id, owner_id) ON DELETE RESTRICT
);

-- 1 คน ทักเรื่องสัตว์ตัวหนึ่งได้ห้องเดียว
-- ถ้าไม่มี constraint นี้ การกดปุ่ม "ทักแชท" รัว ๆ จะสร้างห้องซ้ำหลายห้อง
CREATE UNIQUE INDEX conversations_pet_initiator_key
  ON conversations (pet_id, initiator_id);

-- กล่องข้อความฝั่งเจ้าของ (SKILL.md กำหนดไว้ตรง ๆ)
CREATE INDEX conversations_owner_idx
  ON conversations (owner_id, last_message_at DESC);

-- กล่องข้อความฝั่งคนที่ทักไป (SKILL.md กำหนดไว้ตรง ๆ)
CREATE INDEX conversations_initiator_idx
  ON conversations (initiator_id, last_message_at DESC);

-- "แชททั้งหมดที่เกี่ยวกับสัตว์ตัวนี้" บนหน้า pet detail ของเจ้าของ
CREATE INDEX conversations_pet_idx
  ON conversations (pet_id, last_message_at DESC);

CREATE TRIGGER conversations_set_updated_at
  BEFORE UPDATE ON conversations
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE conversations IS
  'ห้องแชท 1 ห้อง = (สัตว์ 1 ตัว, คนทัก 1 คน) — ห้องเกิดพร้อมข้อความแรกเท่านั้น';


-- -----------------------------------------------------------------------------
-- messages — ข้อความในห้อง
-- -----------------------------------------------------------------------------
CREATE TABLE messages (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid        NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id       uuid        NOT NULL REFERENCES users(id) ON DELETE RESTRICT,

  body            text        NOT NULL,

  read_at         timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now(),

  -- soft delete ของข้อความ — ต้องเก็บตัวข้อความไว้แม้ผู้ส่งจะลบ
  -- เพราะถ้ามีการรายงานคุกคาม หลักฐานต้องยังอยู่ให้ตรวจสอบได้
  deleted_at      timestamptz,

  CONSTRAINT messages_body_not_blank CHECK (length(btrim(body)) > 0),
  -- จำกัดความยาวเพื่อไม่ให้ใครยิงข้อความขนาดหลายเมกะไบต์
  CONSTRAINT messages_body_length    CHECK (length(body) <= 2000)
);

-- ดึงประวัติข้อความแบบ paginate จากใหม่ไปเก่า (SKILL.md กำหนดไว้ตรง ๆ)
CREATE INDEX messages_conversation_idx
  ON messages (conversation_id, created_at DESC, id DESC);

-- ใช้ตอนกดอ่าน: หาข้อความที่ยังไม่ได้อ่านในห้องนี้
-- partial index ทำให้ index มีขนาดเท่าจำนวนข้อความที่ยังไม่ได้อ่านเท่านั้น
-- ซึ่งในระบบจริงมักน้อยมากเมื่อเทียบกับข้อความทั้งหมด
CREATE INDEX messages_unread_idx
  ON messages (conversation_id, sender_id)
  WHERE read_at IS NULL;


-- -----------------------------------------------------------------------------
-- กฎที่ 1: ห้องแชทต้องเกิดพร้อมข้อความแรกเสมอ
--
-- SKILL.md: "การกดถูกใจต้องไม่สร้างห้องแชทอัตโนมัติ — ห้องแชทเกิดตอนผู้ใช้
--            กดส่งข้อความแรกเท่านั้น"
-- และ endpoint: "POST /conversations สร้างห้อง (ต้องมีข้อความแรกเสมอ)"
--
-- CONSTRAINT TRIGGER แบบ DEFERRABLE จะถูกตรวจตอน COMMIT ไม่ใช่ตอน INSERT
-- ทำให้ลำดับนี้ผ่าน:
--     BEGIN; INSERT conversation; INSERT message; COMMIT;   -- ผ่าน
-- แต่ลำดับนี้ไม่ผ่าน:
--     BEGIN; INSERT conversation; COMMIT;                   -- ถูกปฏิเสธ
--
-- ผลคือ "ห้องแชทเปล่า" เกิดขึ้นในฐานข้อมูลนี้ไม่ได้เลย ไม่ว่าจะเขียนโค้ดพลาดยังไง
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION assert_conversation_has_message()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  -- ห้องที่ถูกลบไปแล้วระหว่าง transaction เดียวกันไม่ต้องตรวจ
  IF NOT EXISTS (SELECT 1 FROM conversations WHERE id = NEW.id) THEN
    RETURN NULL;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM messages WHERE conversation_id = NEW.id) THEN
    RAISE EXCEPTION
      'ห้องแชท % ไม่มีข้อความ — ห้องต้องถูกสร้างพร้อมข้อความแรกใน transaction เดียวกัน', NEW.id
      USING ERRCODE = 'check_violation';
  END IF;

  RETURN NULL;
END;
$$;

CREATE CONSTRAINT TRIGGER conversations_require_first_message
  AFTER INSERT ON conversations
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION assert_conversation_has_message();


-- -----------------------------------------------------------------------------
-- กฎที่ 2: ส่งข้อความได้เฉพาะคู่สนทนา 2 คนนั้น และเฉพาะตอนห้องยัง active
--
-- พร้อมกันนั้นก็อัปเดตข้อมูลสรุปของห้อง (ข้อความล่าสุด + ตัวนับที่ยังไม่ได้อ่าน)
-- รวมไว้ใน trigger เดียวเพราะทั้งสองอย่างต้องแตะแถวเดียวกันของ conversations อยู่แล้ว
-- แยกเป็น 2 trigger จะเสียค่า lock แถวเดิมซ้ำโดยไม่จำเป็น
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION on_message_inserted()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  conv conversations%ROWTYPE;
BEGIN
  -- FOR UPDATE กัน race condition ตอนทั้งสองฝ่ายพิมพ์พร้อมกัน
  -- ถ้าไม่ล็อก ตัวนับ unread อาจหายไปหนึ่งครั้ง (lost update)
  SELECT * INTO conv FROM conversations WHERE id = NEW.conversation_id FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'ไม่พบห้องแชท %', NEW.conversation_id
      USING ERRCODE = 'foreign_key_violation';
  END IF;

  IF NEW.sender_id <> conv.initiator_id AND NEW.sender_id <> conv.owner_id THEN
    RAISE EXCEPTION 'ผู้ใช้ % ไม่ใช่คู่สนทนาของห้อง %', NEW.sender_id, NEW.conversation_id
      USING ERRCODE = 'check_violation';
  END IF;

  IF conv.status <> 'active' THEN
    RAISE EXCEPTION 'ห้องแชท % ถูกปิดแล้ว (%) ส่งข้อความใหม่ไม่ได้',
      NEW.conversation_id, conv.closed_reason
      USING ERRCODE = 'check_violation';
  END IF;

  UPDATE conversations SET
    last_message_at        = NEW.created_at,
    last_message_preview   = left(NEW.body, 120),
    last_message_sender_id = NEW.sender_id,
    initiator_unread_count = initiator_unread_count
      + CASE WHEN NEW.sender_id <> initiator_id THEN 1 ELSE 0 END,
    owner_unread_count     = owner_unread_count
      + CASE WHEN NEW.sender_id <> owner_id THEN 1 ELSE 0 END
  WHERE id = NEW.conversation_id;

  RETURN NEW;
END;
$$;

CREATE TRIGGER messages_after_insert
  AFTER INSERT ON messages
  FOR EACH ROW EXECUTE FUNCTION on_message_inserted();


-- -----------------------------------------------------------------------------
-- กฎที่ 3: ปิดห้องแชทอัตโนมัติเมื่อสัตว์ได้บ้านแล้วหรือประกาศถูกลบ
--
-- ถ้าไม่ปิด จะเกิดสถานการณ์ที่ผู้ใช้ยังพิมพ์ถามอยู่เรื่อย ๆ ทั้งที่น้องมีบ้านแล้ว
-- และเจ้าของต้องมานั่งตอบซ้ำทีละคน
--
-- ทำที่ฐานข้อมูลเพราะสถานะสัตว์เปลี่ยนได้จากหลายทาง (แก้ประกาศ, ลบ, แอดมินสั่ง)
-- ถ้าไปทำในชั้น service จะต้องไปเรียกซ้ำทุกทางและมีวันลืมแน่นอน
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION close_conversations_for_pet()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  reason conversation_closed_reason;
BEGIN
  IF NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
    reason := 'pet_deleted';
  ELSIF NEW.status = 'adopted' AND OLD.status <> 'adopted' THEN
    reason := 'pet_adopted';
  ELSE
    RETURN NEW;
  END IF;

  UPDATE conversations
     SET status        = 'closed',
         closed_at     = now(),
         closed_reason = reason
   WHERE pet_id = NEW.id
     AND status = 'active';

  RETURN NEW;
END;
$$;

CREATE TRIGGER pets_close_conversations
  AFTER UPDATE OF status, deleted_at ON pets
  FOR EACH ROW EXECUTE FUNCTION close_conversations_for_pet();

COMMIT;
