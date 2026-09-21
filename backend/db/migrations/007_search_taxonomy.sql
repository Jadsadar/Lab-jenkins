-- =============================================================================
-- 007 — จังหวัด/ภูมิภาค และแท็กนิสัยสัตว์ สำหรับหน้าค้นหา
--
-- ตารางในไฟล์นี้: provinces, traits, pet_traits
--
-- เหตุผลที่ต้องมีไฟล์นี้: หน้าค้นหา (ซึ่งคือหน้า Swipe deck เดิมที่ใส่ตัวกรอง
-- ไม่ใช่หน้าที่ 7 ตามกฎ SKILL.md) ต้องรองรับ 2 อย่างที่ schema เดิมยังไม่มี:
--   1. ค้นหาด้วยแท็กนิสัยของสัตว์ (สายลุย, ติดคน, รักเด็ก ฯลฯ)
--   2. เรียงผลลัพธ์จากจังหวัดใกล้ตัวผู้ใช้ก่อน แล้วค่อยขยายไปทั้งภาค แล้วค่อยทั้งประเทศ
--      (ไม่ใช่ตัวกรองแบบ all-or-nothing เหมือน deck_feed เดิม)
--
-- ไฟล์นี้ต้องรันก่อน 008 (deck_query) เพราะฟังก์ชัน deck_feed เวอร์ชันใหม่
-- ต้อง join ตารางที่นี่
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- provinces — 77 จังหวัดของไทย พร้อมภูมิภาคที่สังกัด
--
-- ใช้ "ชื่อจังหวัด" เป็น primary key ตรง ๆ แทนที่จะสร้าง surrogate id เพราะ:
--   1. users.location และ pets.location เก็บชื่อจังหวัดเป็น free text อยู่แล้ว
--      (ตรงกับ thaiProvinces ในแอป Flutter) การ FK ไปที่ชื่อจึงไม่ต้อง migrate
--      ข้อมูลเดิม แค่เพิ่ม constraint
--   2. ชื่อจังหวัดไทยนิ่งมาก แทบไม่มีการเปลี่ยน ไม่ต้องกังวลเรื่อง "เปลี่ยนคีย์" ภายหลัง
--
-- ผลพลอยได้: users.location และ pets.location จะพิมพ์ผิดไม่ได้อีกต่อไป
-- (ก่อนหน้านี้เป็น varchar(100) อิสระ ใครพิมพ์ "กรุงเทพ" แทน "กรุงเทพมหานคร"
--  จะหลุดจากทุก query ที่กรองด้วยจังหวัดแบบ exact match โดยไม่มี error เตือน)
-- -----------------------------------------------------------------------------
CREATE TABLE provinces (
  name   varchar(100) PRIMARY KEY,
  region thai_region  NOT NULL
);

CREATE INDEX provinces_region_idx ON provinces (region);

-- รายชื่อและภูมิภาคต้องตรงกับ thaiProvinces ใน lib/data/mock_data.dart ทุกตัวอักษร
-- (คัดลอกมาตรง ๆ จากไฟล์นั้นเพื่อกัน FK insert ล้มเหลวเพราะสะกดไม่ตรงกัน)
-- แบ่งภาคตามมาตรฐาน 6 ภาคที่ใช้กันทั่วไป (เหนือ/อีสาน/กลาง/ตะวันออก/ตะวันตก/ใต้)
INSERT INTO provinces (name, region) VALUES
  -- ภาคกลาง (22)
  ('กรุงเทพมหานคร', 'central'), ('กำแพงเพชร', 'central'), ('ชัยนาท', 'central'),
  ('นครนายก', 'central'), ('นครปฐม', 'central'), ('นครสวรรค์', 'central'),
  ('นนทบุรี', 'central'), ('ปทุมธานี', 'central'), ('พระนครศรีอยุธยา', 'central'),
  ('พิจิตร', 'central'), ('พิษณุโลก', 'central'), ('เพชรบูรณ์', 'central'),
  ('ลพบุรี', 'central'), ('สมุทรปราการ', 'central'), ('สมุทรสงคราม', 'central'),
  ('สมุทรสาคร', 'central'), ('สิงห์บุรี', 'central'), ('สุโขทัย', 'central'),
  ('สุพรรณบุรี', 'central'), ('สระบุรี', 'central'), ('อ่างทอง', 'central'),
  ('อุทัยธานี', 'central'),

  -- ภาคเหนือ (9)
  ('เชียงใหม่', 'north'), ('เชียงราย', 'north'), ('ลำปาง', 'north'),
  ('ลำพูน', 'north'), ('แม่ฮ่องสอน', 'north'), ('น่าน', 'north'),
  ('พะเยา', 'north'), ('แพร่', 'north'), ('อุตรดิตถ์', 'north'),

  -- ภาคตะวันออกเฉียงเหนือ / อีสาน (20)
  ('กาฬสินธุ์', 'northeast'), ('ขอนแก่น', 'northeast'), ('ชัยภูมิ', 'northeast'),
  ('นครพนม', 'northeast'), ('นครราชสีมา', 'northeast'), ('บึงกาฬ', 'northeast'),
  ('บุรีรัมย์', 'northeast'), ('มหาสารคาม', 'northeast'), ('มุกดาหาร', 'northeast'),
  ('ยโสธร', 'northeast'), ('ร้อยเอ็ด', 'northeast'), ('เลย', 'northeast'),
  ('ศรีสะเกษ', 'northeast'), ('สกลนคร', 'northeast'), ('สุรินทร์', 'northeast'),
  ('หนองคาย', 'northeast'), ('หนองบัวลำภู', 'northeast'), ('อำนาจเจริญ', 'northeast'),
  ('อุดรธานี', 'northeast'), ('อุบลราชธานี', 'northeast'),

  -- ภาคตะวันออก (7)
  ('จันทบุรี', 'east'), ('ฉะเชิงเทรา', 'east'), ('ชลบุรี', 'east'),
  ('ตราด', 'east'), ('ปราจีนบุรี', 'east'), ('ระยอง', 'east'), ('สระแก้ว', 'east'),

  -- ภาคตะวันตก (5)
  ('กาญจนบุรี', 'west'), ('ตาก', 'west'), ('ประจวบคีรีขันธ์', 'west'),
  ('เพชรบุรี', 'west'), ('ราชบุรี', 'west'),

  -- ภาคใต้ (14)
  ('กระบี่', 'south'), ('ชุมพร', 'south'), ('ตรัง', 'south'),
  ('นครศรีธรรมราช', 'south'), ('นราธิวาส', 'south'), ('ปัตตานี', 'south'),
  ('พังงา', 'south'), ('พัทลุง', 'south'), ('ภูเก็ต', 'south'),
  ('ยะลา', 'south'), ('ระนอง', 'south'), ('สงขลา', 'south'),
  ('สตูล', 'south'), ('สุราษฎร์ธานี', 'south');

-- ต้องได้ 77 แถวพอดี — ถ้าไม่ตรงแปลว่าพิมพ์ตกหรือซ้ำระหว่างก๊อปมา ให้ migration ล้มทันที
DO $check$
BEGIN
  IF (SELECT count(*) FROM provinces) <> 77 THEN
    RAISE EXCEPTION 'provinces ต้องมี 77 แถว แต่พบ % แถว', (SELECT count(*) FROM provinces);
  END IF;
END $check$;

-- ผูก users.location / pets.location เข้ากับ provinces(name)
-- เพิ่มเป็น constraint ทีหลังได้เพราะยังไม่มีข้อมูลจริงในระบบ (โปรเจกต์ยังไม่ launch)
-- ถ้าทำบนฐานข้อมูล production ที่มีข้อมูลอยู่แล้ว ต้องรัน UPDATE แก้ค่าที่สะกดไม่ตรงก่อน
-- ไม่งั้น ALTER TABLE นี้จะ error ทันที
ALTER TABLE users ADD CONSTRAINT users_location_fkey
  FOREIGN KEY (location) REFERENCES provinces(name);

ALTER TABLE pets ADD CONSTRAINT pets_location_fkey
  FOREIGN KEY (location) REFERENCES provinces(name);


-- -----------------------------------------------------------------------------
-- traits — แท็กนิสัย/บุคลิกที่เลือกได้ตอนลงประกาศ
--
-- ใช้ตารางแบบมีคีย์จริง (ไม่ใช่ native enum แบบ pet_status) เพราะชุดแท็กนี้
-- เป็นข้อมูลที่แอดมิน "แก้ไข/เพิ่ม/ปิดใช้งาน" ได้โดยไม่ต้อง deploy โค้ดใหม่
-- ต่างจาก enum ของ Postgres ที่เพิ่มค่าได้แต่ "ลบ" ไม่ได้เลยตลอดอายุฐานข้อมูล
--
-- ⚠️ แหล่งความจริงของชุดแท็กคือ lib/utils/pet_tags.dart (petTags) ไม่ใช่ที่นี่
-- ก่อนหน้านี้เคยมี 3 ชุดที่ไม่ตรงกัน (mock_data.dart เก่า, ไฟล์นี้, pet_tags.dart)
-- ตอนนี้รวมเหลือชุดเดียวคือ petTags แล้ว 10 slug ด้านล่างต้องตรงกับ
-- petTags.id ในไฟล์นั้นเป๊ะ ๆ เสมอ ถ้าจะเพิ่ม/แก้แท็กต้องแก้ทั้งสองที่พร้อมกัน
-- จนกว่าจะมี endpoint GET /traits ให้ Flutter ดึงจาก DB โดยตรง (ROADMAP.md Phase 3.8)
-- -----------------------------------------------------------------------------
CREATE TABLE traits (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  slug       varchar(40) NOT NULL,
  label_th   varchar(40) NOT NULL,
  sort_order smallint    NOT NULL DEFAULT 0,
  is_active  boolean     NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX traits_slug_key ON traits (slug);
-- รายการที่ยังใช้อยู่ เรียงตามลำดับที่ต้องการโชว์ในฟอร์ม
CREATE INDEX traits_active_idx ON traits (sort_order) WHERE is_active;

-- ต้องตรงกับ petTags ใน lib/utils/pet_tags.dart ทั้ง slug และลำดับ
INSERT INTO traits (slug, label_th, sort_order) VALUES
  ('energetic',    'พลังเยอะ', 0),
  ('chill',        'สายชิล', 1),
  ('affectionate', 'ขี้อ้อน', 2),
  ('independent',  'รักอิสระ', 3),
  ('talkative',    'ช่างคุย', 4),
  ('quiet',        'รักความสงบ', 5),
  ('social',       'เข้าสังคมเก่ง', 6),
  ('kid_friendly', 'รักเด็ก', 7),
  ('foodie',       'สายกิน', 8),
  ('tidy',         'รักความสะอาด', 9);

COMMENT ON TABLE traits IS
  'ชุดแท็กนิสัยที่แก้ไขได้จากฝั่งแอดมิน ตั้งใจไม่ใช้ native enum เพราะลบค่าไม่ได้';
COMMENT ON COLUMN traits.is_active IS
  'ปิดแท็กที่ไม่ใช้แล้วด้วยค่านี้ ห้ามลบแถวจริงเพราะ pet_traits เก่ายังอ้างอิงอยู่';


-- -----------------------------------------------------------------------------
-- pet_traits — สัตว์ 1 ตัว มีได้หลายแท็ก (many-to-many)
-- -----------------------------------------------------------------------------
CREATE TABLE pet_traits (
  pet_id   uuid NOT NULL REFERENCES pets(id)   ON DELETE CASCADE,
  trait_id uuid NOT NULL REFERENCES traits(id) ON DELETE RESTRICT,

  PRIMARY KEY (pet_id, trait_id)
);

-- "หาสัตว์ที่มีแท็กนี้" — ทิศทางย้อนกลับจาก PK ซึ่งครอบแค่ pet_id ก่อน
CREATE INDEX pet_traits_trait_idx ON pet_traits (trait_id);

COMMENT ON TABLE pet_traits IS
  'ความสัมพันธ์หลายต่อหลายระหว่างสัตว์กับแท็กนิสัย ใช้กรอง/แสดงผลในหน้าค้นหา';

COMMIT;
