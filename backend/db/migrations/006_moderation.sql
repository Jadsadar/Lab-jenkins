-- =============================================================================
-- 006 — การบล็อกและการรายงาน
--
-- ตารางในไฟล์นี้: blocks, reports
--
-- แอปนี้เปิดให้คนแปลกหน้าส่งข้อความหากันได้โดยตรง ถ้าไม่มีสองตารางนี้
-- ผู้ใช้ที่ถูกคุกคามจะไม่มีทางออกเลยนอกจากลบบัญชีทิ้ง
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- blocks — ผู้ใช้บล็อกผู้ใช้
--
-- ผลที่ต้องเกิดเมื่อ A บล็อก B:
--   1. สัตว์ของ B ไม่โผล่ใน deck ของ A และสัตว์ของ A ไม่โผล่ใน deck ของ B
--      (บล็อกมีผลสองทางเสมอ ไม่งั้นคนบล็อกยังโดนคนที่ตัวเองบล็อกปัดเจออยู่ดี)
--   2. ห้องแชทระหว่างทั้งคู่ถูกปิด
--   3. ทั้งคู่ส่งข้อความหากันไม่ได้
--
-- ใช้ composite primary key แทน id แยก เพราะคู่ (blocker, blocked)
-- คือตัวตนของแถวนี้จริง ๆ ไม่มีเหตุผลให้มีคีย์สังเคราะห์
-- -----------------------------------------------------------------------------
CREATE TABLE blocks (
  blocker_id uuid        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  blocked_id uuid        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reason     varchar(200),
  created_at timestamptz NOT NULL DEFAULT now(),

  PRIMARY KEY (blocker_id, blocked_id),
  CONSTRAINT blocks_no_self CHECK (blocker_id <> blocked_id)
);

-- ใช้ตอบคำถาม "ใครบล็อกฉันไว้บ้าง" ซึ่ง query ของ deck ต้องใช้
-- primary key ครอบเฉพาะทิศ blocker -> blocked เท่านั้น จึงต้องมี index ย้อนกลับ
CREATE INDEX blocks_blocked_idx ON blocks (blocked_id);

COMMENT ON TABLE blocks IS 'การบล็อกมีผลสองทางเสมอ — deck ต้องกรองทั้งสองทิศ';


-- -----------------------------------------------------------------------------
-- reports — รายงานเนื้อหาที่ไม่เหมาะสม
--
-- รายงานได้ 3 อย่าง: ประกาศสัตว์, ผู้ใช้, ข้อความในแชท
--
-- แทนที่จะใช้ target_type + target_id แบบ polymorphic (ซึ่งทำ foreign key ไม่ได้
-- และเปิดทางให้มีแถวชี้ไปยัง id ที่ไม่มีอยู่จริง) ใช้คอลัมน์แยกที่เป็น FK จริง
-- แล้วบังคับด้วย CHECK ว่าต้องมีค่าพอดี 1 คอลัมน์
--
-- แลกความยืดหยุ่นบางส่วนกับการที่ฐานข้อมูลรับประกันความถูกต้องให้ ซึ่งคุ้มกว่า
-- -----------------------------------------------------------------------------
CREATE TABLE reports (
  id          uuid          PRIMARY KEY DEFAULT gen_random_uuid(),

  reporter_id uuid          NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  reported_pet_id     uuid  REFERENCES pets(id)    ON DELETE CASCADE,
  reported_user_id    uuid  REFERENCES users(id)   ON DELETE CASCADE,
  reported_message_id uuid  REFERENCES messages(id) ON DELETE CASCADE,

  reason      report_reason NOT NULL,
  detail      varchar(500),

  status      report_status NOT NULL DEFAULT 'pending',
  reviewed_by uuid          REFERENCES users(id) ON DELETE SET NULL,
  reviewed_at timestamptz,
  review_note varchar(500),

  created_at  timestamptz   NOT NULL DEFAULT now(),

  -- ต้องระบุเป้าหมายพอดี 1 อย่าง ไม่มากไม่น้อย
  CONSTRAINT reports_exactly_one_target CHECK (
    (reported_pet_id     IS NOT NULL)::int +
    (reported_user_id    IS NOT NULL)::int +
    (reported_message_id IS NOT NULL)::int = 1
  ),

  CONSTRAINT reports_not_self CHECK (
    reported_user_id IS NULL OR reported_user_id <> reporter_id
  ),

  CONSTRAINT reports_reviewed_consistent CHECK (
    (status IN ('pending', 'reviewing') AND reviewed_at IS NULL) OR
    (status IN ('actioned', 'dismissed') AND reviewed_at IS NOT NULL)
  )
);

-- 1 คน รายงาน 1 เป้าหมาย ได้ครั้งเดียว — กันการกดรัวเพื่อปั่นยอดรายงาน
-- ต้องใช้ partial unique index แยกกัน 3 อัน เพราะใน Postgres ค่า NULL
-- ไม่ถือว่าซ้ำกัน unique ธรรมดาบน 4 คอลัมน์จึงกันซ้ำไม่ได้จริง
CREATE UNIQUE INDEX reports_unique_pet
  ON reports (reporter_id, reported_pet_id)     WHERE reported_pet_id IS NOT NULL;
CREATE UNIQUE INDEX reports_unique_user
  ON reports (reporter_id, reported_user_id)    WHERE reported_user_id IS NOT NULL;
CREATE UNIQUE INDEX reports_unique_message
  ON reports (reporter_id, reported_message_id) WHERE reported_message_id IS NOT NULL;

-- คิวงานของแอดมิน: เรื่องที่ยังไม่ได้ตรวจ เรียงจากเก่าไปใหม่
CREATE INDEX reports_queue_idx
  ON reports (created_at)
  WHERE status IN ('pending', 'reviewing');

CREATE INDEX reports_pet_idx ON reports (reported_pet_id) WHERE reported_pet_id IS NOT NULL;


-- -----------------------------------------------------------------------------
-- ดูแล pets.report_count ให้ตรงเสมอ
--
-- ใช้ตัดสินใจซ่อนประกาศอัตโนมัติเมื่อถูกรายงานถึงเกณฑ์ โดยไม่ต้องรอแอดมิน
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sync_pet_report_count()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.reported_pet_id IS NOT NULL THEN
    UPDATE pets SET report_count = report_count + 1 WHERE id = NEW.reported_pet_id;
  ELSIF TG_OP = 'DELETE' AND OLD.reported_pet_id IS NOT NULL THEN
    UPDATE pets SET report_count = GREATEST(report_count - 1, 0) WHERE id = OLD.reported_pet_id;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER reports_sync_pet_report_count
  AFTER INSERT OR DELETE ON reports
  FOR EACH ROW EXECUTE FUNCTION sync_pet_report_count();


-- -----------------------------------------------------------------------------
-- ปิดห้องแชทอัตโนมัติเมื่อมีการบล็อก
--
-- ปิดทุกห้องที่ทั้งสองคนอยู่ด้วยกัน ไม่ว่าใครเป็นคนทักก่อนหรือเป็นเจ้าของสัตว์
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION close_conversations_on_block()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE conversations
     SET status        = 'closed',
         closed_at     = now(),
         closed_reason = 'blocked'
   WHERE status = 'active'
     AND (
       (initiator_id = NEW.blocker_id AND owner_id     = NEW.blocked_id) OR
       (initiator_id = NEW.blocked_id AND owner_id     = NEW.blocker_id)
     );
  RETURN NEW;
END;
$$;

CREATE TRIGGER blocks_close_conversations
  AFTER INSERT ON blocks
  FOR EACH ROW EXECUTE FUNCTION close_conversations_on_block();

COMMIT;
