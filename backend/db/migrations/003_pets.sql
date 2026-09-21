-- =============================================================================
-- 003 — ประกาศหาบ้านและรูปภาพ
--
-- ตารางในไฟล์นี้: pets, pet_media, media_uploads
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- pets — ประกาศหาบ้าน 1 รายการ
--
-- กฎจาก SKILL.md ที่ schema นี้บังคับใช้:
--   "Pet 1 ตัว มีเจ้าของได้คนเดียว (pet.owner_id เป็น field เดียว ไม่ใช่ตาราง join)
--    ห้ามทำ co-owner หรือ many-to-many"
--
-- owner_id จึงเป็นคอลัมน์ NOT NULL ธรรมดา และจะ **ไม่มี** ตาราง pet_owners
-- โครงสร้างนี้ทำให้เขียนโค้ด co-owner ไม่ได้เลยแม้จะเผลอ ไม่ใช่แค่ข้อตกลงบนกระดาษ
-- -----------------------------------------------------------------------------
CREATE TABLE pets (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),

  -- ON DELETE RESTRICT: ลบ user ที่ยังมีประกาศอยู่ไม่ได้
  -- บังคับให้ชั้น application ต้องจัดการประกาศก่อน (soft delete ทั้งหมด)
  -- แทนที่จะปล่อยให้ CASCADE ลบประกาศหายไปพร้อมห้องแชทของคนอื่น
  owner_id    uuid        NOT NULL REFERENCES users(id) ON DELETE RESTRICT,

  name        varchar(50) NOT NULL,
  species     pet_species NOT NULL DEFAULT 'dog',
  breed       varchar(80),

  -- เก็บอายุเป็น "จำนวนเดือน" ไม่ใช่ข้อความอย่าง "2 ปี"
  -- เพราะต้องใช้เรียงลำดับและกรองช่วงอายุ ซึ่งทำกับข้อความไม่ได้
  -- NULL = ไม่ทราบอายุ (สัตว์จรมักไม่รู้จริง ๆ) จึงต้องยอมให้ว่างได้
  age_months  int,

  sex         pet_sex     NOT NULL DEFAULT 'unknown',
  size        pet_size,

  vaccinated  boolean     NOT NULL DEFAULT false,
  neutered    boolean     NOT NULL DEFAULT false,

  weight_kg   numeric(5,2),
  description text,

  location    varchar(100) NOT NULL,

  status      pet_status  NOT NULL DEFAULT 'available',
  adopted_at  timestamptz,

  -- ตัวนับที่ระบบดูแลเองผ่าน trigger ไม่ใช่ค่าที่ client ส่งมา
  -- มีไว้เพื่อไม่ต้อง COUNT(*) ทุกครั้งที่แสดงการ์ด
  like_count   int NOT NULL DEFAULT 0,
  report_count int NOT NULL DEFAULT 0,

  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),

  -- soft delete — ลบจริงจะทำให้ห้องแชทและประวัติถูกใจของคนอื่นพังตามไปด้วย
  deleted_at  timestamptz,

  CONSTRAINT pets_name_not_blank   CHECK (length(btrim(name)) > 0),
  CONSTRAINT pets_age_months_range CHECK (age_months IS NULL OR age_months BETWEEN 0 AND 360),
  CONSTRAINT pets_weight_range     CHECK (weight_kg IS NULL OR weight_kg > 0),
  CONSTRAINT pets_counters_non_negative CHECK (like_count >= 0 AND report_count >= 0),
  -- สถานะ adopted ต้องมีวันที่กำกับเสมอ และสถานะอื่นต้องไม่มี
  CONSTRAINT pets_adopted_at_consistent CHECK (
    (status = 'adopted' AND adopted_at IS NOT NULL) OR
    (status <> 'adopted' AND adopted_at IS NULL)
  )
);

-- คีย์ประกอบนี้ไม่ได้มีไว้ค้นหา แต่มีไว้ให้ตาราง conversations อ้างอิงแบบคู่
-- (pet_id, owner_id) ได้ ทำให้ owner_id ที่ทำซ้ำไว้ในห้องแชท
-- **เป็นไปไม่ได้เลย** ที่จะไม่ตรงกับเจ้าของจริงของสัตว์ตัวนั้น
CREATE UNIQUE INDEX pets_id_owner_id_key ON pets (id, owner_id);

-- index หลักของ deck: หาสัตว์ที่ยัง available เรียงจากใหม่ไปเก่า
-- ใส่ id ต่อท้ายเพื่อให้ทำ keyset pagination ได้แบบไม่มีแถวซ้ำหรือตกหล่น
-- เมื่อ created_at ชนกันพอดี
-- partial index (WHERE deleted_at IS NULL) ทำให้ index เล็กลงและไม่ต้องอ่านแถวที่ลบแล้ว
CREATE INDEX pets_deck_idx
  ON pets (status, created_at DESC, id DESC)
  WHERE deleted_at IS NULL;

-- deck ที่กรองตามจังหวัด
CREATE INDEX pets_deck_location_idx
  ON pets (status, location, created_at DESC, id DESC)
  WHERE deleted_at IS NULL;

-- โพสสัตว์ทั้งหมดของเจ้าของ 1 คน (หน้า Profile)
-- ไม่กรอง status เพราะโปรไฟล์ต้องโชว์ตัวที่ adopted แล้วด้วยพร้อมป้ายสถานะ
CREATE INDEX pets_owner_idx
  ON pets (owner_id, created_at DESC)
  WHERE deleted_at IS NULL;

-- ค้นหาชื่อ/สายพันธุ์แบบบางส่วน
CREATE INDEX pets_name_trgm_idx ON pets USING gin (name gin_trgm_ops);

CREATE TRIGGER pets_set_updated_at
  BEFORE UPDATE ON pets
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE pets IS 'ประกาศหาบ้าน — เจ้าของได้คนเดียวเท่านั้น ห้ามเพิ่มตาราง join เจ้าของ';
COMMENT ON COLUMN pets.age_months IS 'อายุเป็นเดือน เพื่อให้กรองช่วงอายุและเรียงลำดับได้ NULL = ไม่ทราบ';
COMMENT ON COLUMN pets.like_count IS 'ดูแลโดย trigger เท่านั้น API ห้ามเขียนทับ';


-- -----------------------------------------------------------------------------
-- pet_media — รูป (และวิดีโอสั้นในอนาคต) ของสัตว์ 1 ตัว เรียงลำดับได้
--
-- ชื่อ pet_media ไม่ใช่ pet_photos ตั้งแต่แรก เพราะแผนถัดไปคือรองรับวิดีโอสั้น
-- (ตามที่ผู้ใช้ระบุไว้ในแผนงาน) ถ้าตั้งชื่อ/ออกแบบเป็น "รูปอย่างเดียว" ตอนนี้
-- วันที่เพิ่มวิดีโอจะต้อง rename ตารางที่มีข้อมูลจริงอยู่แล้ว ซึ่งเสี่ยงกว่ามาก
-- เมื่อเทียบกับการเผื่อ media_type ไว้ตั้งแต่ตอนที่ยังไม่มีข้อมูล
--
-- ตอนนี้ (เฟสแรก) ทุกแถวจะเป็น media_type = 'photo' เท่านั้น API ฝั่งอัปโหลด
-- จะยังไม่เปิดให้ส่ง 'video' จนกว่าจะพร้อม — ฝั่งฐานข้อมูลรองรับไว้ล่วงหน้าแล้ว
--
-- แยกเป็นตารางแทนที่จะเก็บเป็น array ของ URL บน pets เพราะ:
--   1. ต้องเก็บ storage_key ไว้ลบไฟล์จริงบน S3 ตอนลบ
--   2. ต้องเก็บขนาดภาพ/ความยาววิดีโอไว้กัน layout กระโดดตอนโหลด
--   3. การ์ดใน deck ขอแค่สื่อชิ้นแรก — query ชิ้นเดียวได้โดยไม่ต้องดึงทั้งก้อน
-- -----------------------------------------------------------------------------
CREATE TABLE pet_media (
  id          uuid           PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id      uuid           NOT NULL REFERENCES pets(id) ON DELETE CASCADE,

  media_type  pet_media_type NOT NULL DEFAULT 'photo',

  -- path บน object storage เช่น 'pets/{pet_id}/{uuid}.jpg'
  -- จำเป็นสำหรับการลบไฟล์จริงและสร้าง presigned URL ตอนอ่าน
  storage_key varchar(500)   NOT NULL,

  -- URL สาธารณะผ่าน CDN — เก็บไว้เพื่อไม่ต้องประกอบใหม่ทุกครั้ง
  url         text           NOT NULL,
  thumb_url   text,

  width       int,
  height      int,
  bytes       bigint,

  -- เฉพาะ video เท่านั้น ใช้โชว์ความยาวคลิปในการ์ด และจำกัดไม่ให้อัปคลิปยาวเกินไป
  duration_seconds numeric(6,2),

  -- ลำดับการแสดงผล เริ่มที่ 0 = สื่อหลักที่โชว์บนการ์ด
  sort_order  smallint       NOT NULL DEFAULT 0,

  created_at  timestamptz    NOT NULL DEFAULT now(),

  CONSTRAINT pet_media_sort_order_range CHECK (sort_order BETWEEN 0 AND 9),
  -- เฉพาะ video เท่านั้นที่มี duration และต้องไม่เกิน 60 วินาที (คลิปสั้น ไม่ใช่ reels ยาว)
  CONSTRAINT pet_media_duration_consistent CHECK (
    (media_type = 'video' AND duration_seconds IS NOT NULL AND duration_seconds BETWEEN 0 AND 60) OR
    (media_type = 'photo' AND duration_seconds IS NULL)
  )
);

-- ห้ามมีสื่อ 2 ชิ้นที่ลำดับเดียวกันในสัตว์ตัวเดียวกัน ไม่งั้นลำดับจะสุ่มไปมา
CREATE UNIQUE INDEX pet_media_pet_sort_key ON pet_media (pet_id, sort_order);
CREATE INDEX        pet_media_pet_idx      ON pet_media (pet_id);
CREATE UNIQUE INDEX pet_media_storage_key  ON pet_media (storage_key);

COMMENT ON TABLE pet_media IS
  'รูป/วิดีโอของสัตว์ — เฟสแรกมีแต่ photo, video เปิดใช้ภายหลังโดยไม่ต้อง migrate schema';
COMMENT ON COLUMN pet_media.sort_order IS 'ลำดับแสดงผล 0 = สื่อหลักบนการ์ด จำกัดสูงสุด 10 ชิ้นต่อตัว';


-- -----------------------------------------------------------------------------
-- media_uploads — ติดตามไฟล์ที่อัปโหลดผ่าน presigned URL
--
-- ปัญหาที่ตารางนี้แก้:
-- การอัปโหลดแบบ presigned URL คือ client ยิงไฟล์ขึ้น S3 "ตรง ๆ" โดยไม่ผ่าน backend
-- แปลว่า backend ไม่มีทางรู้เลยว่าไฟล์ถูกอัปขึ้นไปจริงหรือไม่
--
-- สถานการณ์จริงที่เกิดบ่อย: ผู้ใช้เลือกรูป ระบบออก presigned URL ให้ ไฟล์อัปขึ้นสำเร็จ
-- แล้วผู้ใช้กดปิดแอปก่อนกดโพสต์ — ไฟล์นั้นจะค้างอยู่บน S3 ตลอดกาล
-- ไม่มีแถวไหนในฐานข้อมูลอ้างถึง และไม่มีใครรู้ว่ามันมีอยู่ แต่เสียเงินทุกเดือน
--
-- ตารางนี้บันทึกทุกใบอนุญาตอัปโหลดที่ออกไป งานกวาดล้างจะไล่ลบไฟล์ที่
-- ออกไปเกิน 24 ชั่วโมงแล้วยังไม่ถูกผูกกับ pet ตัวไหน
-- -----------------------------------------------------------------------------
CREATE TABLE media_uploads (
  id           uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid         NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  storage_key  varchar(500) NOT NULL,
  content_type varchar(100) NOT NULL,
  bytes        bigint,

  -- เวลาที่ presigned URL หมดอายุ
  expires_at   timestamptz  NOT NULL,

  -- เซ็ตเมื่อไฟล์ถูกผูกกับ pet_media สำเร็จ — NULL = ยังลอยอยู่ รอถูกกวาด
  claimed_at   timestamptz,

  created_at   timestamptz  NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX media_uploads_storage_key_key ON media_uploads (storage_key);
CREATE INDEX        media_uploads_user_idx        ON media_uploads (user_id);

-- index ของงานกวาดล้าง: หาไฟล์ที่ยังไม่ถูกผูกและเลยเวลาแล้ว
CREATE INDEX media_uploads_orphan_idx
  ON media_uploads (created_at)
  WHERE claimed_at IS NULL;

COMMENT ON TABLE media_uploads IS
  'ติดตามไฟล์ที่อัปผ่าน presigned URL เพื่อกวาดไฟล์ที่อัปแล้วแต่ไม่เคยถูกใช้ทิ้ง';

COMMIT;
