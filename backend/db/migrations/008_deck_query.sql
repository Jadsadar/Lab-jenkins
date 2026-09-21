-- =============================================================================
-- 008 — ฟังก์ชัน query ของ deck / หน้าค้นหา
--
-- SKILL.md กำหนดว่า deck ต้อง:
--   - กรองในฐานข้อมูล ไม่ใช่ดึงมาทั้งหมดแล้วกรองใน memory
--   - ตัดสัตว์ของตัวเอง / ตัวที่เคย like หรือ pass แล้ว / ตัวที่ adopted
--   - ใช้ keyset pagination ไม่ใช่ OFFSET
--   - ตอบใน < 100ms
--
-- เพิ่มเติมจากสเปคเดิม (ตามที่ผู้ใช้อธิบาย flow "หน้าค้นหา"):
--   - กรองด้วยแท็กนิสัยของสัตว์ (pet_traits) — ระบุแท็กใดแท็กหนึ่งก็พอ (ANY match)
--   - เรียงผลลัพธ์ให้ "จังหวัดเดียวกับผู้ใช้" มาก่อน แล้ว "ภาคเดียวกัน" แล้วค่อยที่เหลือ
--     แทนที่จะกรองแบบ all-or-nothing เหมือน p_location เดิม (ซึ่งยังใช้ได้อยู่
--     เป็นตัวกรองแบบเจาะจงจังหวัดเดียว ถ้าผู้ใช้เลือกกรองเองในฟอร์ม)
--
-- เก็บไว้เป็นฟังก์ชันในฐานข้อมูลเพื่อให้เงื่อนไขการกรองมีอยู่ "ที่เดียว"
-- ถ้ากระจายอยู่ในโค้ดหลายที่ วันหนึ่งจะมี query ที่ลืมกรองสัตว์ตัวเอง
--
-- ไฟล์นี้ต้องรันหลัง 007 (search_taxonomy) เพราะ join ตาราง provinces/pet_traits
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- deck_feed — ดึงการ์ดชุดถัดไปสำหรับผู้ใช้ 1 คน
--
-- keyset pagination แบบ 3 ชั้น: (proximity_rank ASC, created_at DESC, id DESC)
-- ทิศทางการเรียงไม่เหมือนกันในแต่ละชั้น (rank น้อยมาก่อน แต่เวลาใหม่มาก่อน)
-- จึงเทียบ cursor ด้วยเงื่อนไข OR แยกเป็นชั้น ๆ แทนการเทียบ tuple ตรง ๆ
-- (tuple comparison ของ Postgres ใช้ operator < ตัวเดียวกันทุกช่อง เทียบแบบ
--  ทิศทางผสมกันไม่ได้)
--
-- proximity_rank ไม่ได้มาจาก index (คำนวณสดจาก provinces ของ viewer/pet)
-- แต่คำนวณ "หลัง" กรองด้วย index ทุกตัวแล้ว (status, ไม่ใช่ของตัวเอง, ไม่เคยปัด,
-- ไม่ถูกบล็อก) เซตที่เหลือให้เรียงจึงเล็กพอที่ Postgres sort ในหน่วยความจำได้เร็ว
-- โดยไม่ต้องมี index รองรับ proximity_rank โดยตรง
--
-- ทำไมไม่ใช้ OFFSET: OFFSET 1000 บังคับให้ฐานข้อมูลอ่านและทิ้ง 1000 แถวแรกทุกครั้ง
-- และถ้ามีประกาศใหม่แทรกเข้ามาระหว่างหน้า การ์ดจะซ้ำหรือหายไปเงียบ ๆ
--
-- ⚠️ ตั้งใจเขียนฟังก์ชันนี้แบบ flat SELECT เดี่ยว ไม่ใช้ WITH (CTE) แม้จะอ่าน
-- ยากกว่า เพราะ Postgres มีโอกาส "inline" ฟังก์ชัน LANGUAGE SQL ที่เป็น SELECT
-- เดี่ยวเข้ากับ query ของผู้เรียกได้ (ให้ LIMIT/ORDER BY ผลักลงไปช่วยตัดงาน)
-- แต่พอมี WITH แม้เป็น CTE ธรรมดาไม่ recursive ก็มีโอกาสกลายเป็น optimization
-- fence ที่ inline ไม่ได้ ต้องคำนวณทั้งก้อนก่อนค่อยกรอง/เรียงชั้นนอก — นี่คือ
-- พฤติกรรมมาตรฐานของ Postgres ไม่ใช่การเดา แต่ตัวเลขที่วัดได้จริงในเครื่องนี้
-- แกว่งเยอะระหว่างรอบทดสอบ (แปรผันตามสถานะ cache/planner ของแต่ละ session)
-- จึงไม่ระบุตัวคูณที่แน่นอน — ตัวเลขที่ยืนยันได้และนิ่งคือ "ฟังก์ชันเวอร์ชัน
-- ไม่มี WITH นี้" วัดซ้ำได้คงที่ที่ 18-25ms ด้วยข้อมูล 5,000 ประกาศ ทุกรูปแบบ
-- การเรียก (หน้าแรก / กรองแท็ก / มี cursor หน้า 2) ดู db/README.md หัวข้อ
-- "ผลการทดสอบจริง" สำหรับตัวเลขเต็ม
--
-- ด้วยเหตุนี้ CASE คำนวณ proximity_rank จึงถูก "เขียนซ้ำ" ทั้งใน SELECT, WHERE
-- (3 ที่สำหรับ cursor แต่ละชั้น) และ ORDER BY แทนที่จะคำนวณครั้งเดียวแล้วอ้างชื่อ
-- คอลัมน์ซ้ำผ่าน CTE/subquery
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION deck_feed(
  p_viewer_id    uuid,
  p_limit        int         DEFAULT 20,
  p_cursor_rank  int         DEFAULT NULL,   -- proximity_rank ของใบสุดท้ายในหน้าก่อน
  p_cursor_at    timestamptz DEFAULT NULL,
  p_cursor_id    uuid        DEFAULT NULL,
  p_location     varchar     DEFAULT NULL,   -- ตัวกรองเจาะจงจังหวัดเดียว (ถ้าผู้ใช้เลือกเอง)
  p_species      pet_species DEFAULT NULL,
  p_trait_ids    uuid[]      DEFAULT NULL    -- กรองแท็กนิสัย ตรงแท็กใดแท็กหนึ่งพอ
)
RETURNS TABLE (
  id             uuid,
  owner_id       uuid,
  name           varchar,
  species        pet_species,
  breed          varchar,
  age_months     int,
  sex            pet_sex,
  size           pet_size,
  location       varchar,
  like_count     int,
  created_at     timestamptz,
  media_url      text,
  owner_name     varchar,
  owner_avatar   text,
  proximity_rank int        -- 0 = จังหวัดเดียวกับผู้ดู, 1 = ภาคเดียวกัน, 2 = อื่น ๆ
)
LANGUAGE sql
STABLE
AS $$
  SELECT
    p.id, p.owner_id, p.name, p.species, p.breed, p.age_months, p.sex, p.size,
    p.location, p.like_count, p.created_at,
    -- LATERAL ดึงสื่อชิ้นแรกของแต่ละตัวในรอบเดียว ไม่ใช่ loop query ทีละตัว (กัน N+1)
    pm.url AS media_url,
    u.display_name AS owner_name,
    u.avatar_url AS owner_avatar,
    CASE
      -- ผู้ใช้เลือกกรองจังหวัดเดียวเองแล้ว ทุกแถวที่เหลือ "ใกล้เท่ากันหมด"
      WHEN p_location IS NOT NULL THEN 0
      WHEN p.location = viewer.province THEN 0
      WHEN pv_pet.region IS NOT NULL AND pv_pet.region = viewer.region THEN 1
      ELSE 2
    END AS proximity_rank
  FROM pets p
  JOIN users u ON u.id = p.owner_id
  -- ตำแหน่งอ้างอิงของผู้ดู มาจากจังหวัดในโปรไฟล์ตัวเอง ไม่ขึ้นกับ p จึงไม่ต้องใช้ LATERAL
  -- (ประเมินครั้งเดียว ไม่ใช่ต่อแถว) ถ้ายังไม่ตั้งจังหวัด (ไม่ควรเกิดเพราะ users.location
  -- เป็น NOT NULL) region จะเป็น NULL แล้วทุกตัวจะตกไปอยู่ rank 2 เหมือนไม่มีการจัดลำดับพิเศษ
  CROSS JOIN (
    SELECT u2.location AS province, pv.region AS region
    FROM users u2
    LEFT JOIN provinces pv ON pv.name = u2.location
    WHERE u2.id = p_viewer_id
  ) viewer
  LEFT JOIN provinces pv_pet ON pv_pet.name = p.location
  LEFT JOIN LATERAL (
    SELECT pm.url
    FROM pet_media pm
    WHERE pm.pet_id = p.id
    ORDER BY pm.sort_order
    LIMIT 1
  ) pm ON true
  WHERE p.deleted_at IS NULL
    AND p.status = 'available'
    AND p.report_count < 5

    -- ห้ามปัดสัตว์ของตัวเอง (SKILL.md บังคับให้กรองที่ชั้น query)
    AND p.owner_id <> p_viewer_id

    -- เจ้าของต้องยังใช้งานอยู่
    AND u.deleted_at IS NULL
    AND u.is_suspended = false

    -- ตัวที่เคยถูกใจไปแล้ว
    AND NOT EXISTS (
      SELECT 1 FROM likes l
      WHERE l.user_id = p_viewer_id AND l.pet_id = p.id
    )

    -- ตัวที่เคยปัดซ้ายไปแล้ว
    AND NOT EXISTS (
      SELECT 1 FROM passes pa
      WHERE pa.user_id = p_viewer_id AND pa.pet_id = p.id
    )

    -- การบล็อกมีผลสองทาง: ไม่ว่าใครบล็อกใคร ก็ต้องไม่เห็นกัน
    AND NOT EXISTS (
      SELECT 1 FROM blocks b
      WHERE (b.blocker_id = p_viewer_id AND b.blocked_id = p.owner_id)
         OR (b.blocker_id = p.owner_id  AND b.blocked_id = p_viewer_id)
    )

    AND (p_location IS NULL OR p.location = p_location)
    AND (p_species  IS NULL OR p.species  = p_species)

    -- แท็กนิสัย: ต้องมีอย่างน้อย 1 แท็กที่ตรงกับที่ขอมา (ANY match ไม่ใช่ต้องครบทุกแท็ก)
    AND (
      p_trait_ids IS NULL OR EXISTS (
        SELECT 1 FROM pet_traits pt
        WHERE pt.pet_id = p.id AND pt.trait_id = ANY(p_trait_ids)
      )
    )

    -- cursor: ต้อง "มาทีหลัง" แถวสุดท้ายของหน้าก่อนตามลำดับ (rank ASC, created_at DESC, id DESC)
    -- คำนวณ CASE ซ้ำตรงนี้แทนการอ้างชื่อคอลัมน์ proximity_rank เพราะ SQL ไม่ให้
    -- อ้าง SELECT alias ใน WHERE ของ query เดียวกัน (ดูเหตุผลที่ไม่ใช้ CTE/subquery
    -- ห่อไว้ที่คอมเมนต์บนสุดของฟังก์ชัน)
    AND (
      p_cursor_at IS NULL
      OR (CASE
            WHEN p_location IS NOT NULL THEN 0
            WHEN p.location = viewer.province THEN 0
            WHEN pv_pet.region IS NOT NULL AND pv_pet.region = viewer.region THEN 1
            ELSE 2
          END) > COALESCE(p_cursor_rank, 0)
      OR (
        (CASE
           WHEN p_location IS NOT NULL THEN 0
           WHEN p.location = viewer.province THEN 0
           WHEN pv_pet.region IS NOT NULL AND pv_pet.region = viewer.region THEN 1
           ELSE 2
         END) = COALESCE(p_cursor_rank, 0)
        AND p.created_at < p_cursor_at
      )
      OR (
        (CASE
           WHEN p_location IS NOT NULL THEN 0
           WHEN p.location = viewer.province THEN 0
           WHEN pv_pet.region IS NOT NULL AND pv_pet.region = viewer.region THEN 1
           ELSE 2
         END) = COALESCE(p_cursor_rank, 0)
        AND p.created_at = p_cursor_at AND p.id < p_cursor_id
      )
    )

  ORDER BY
    (CASE
       WHEN p_location IS NOT NULL THEN 0
       WHEN p.location = viewer.province THEN 0
       WHEN pv_pet.region IS NOT NULL AND pv_pet.region = viewer.region THEN 1
       ELSE 2
     END) ASC,
    p.created_at DESC,
    p.id DESC
  LIMIT LEAST(GREATEST(p_limit, 1), 50);
$$;

COMMENT ON FUNCTION deck_feed IS
  'query เดียวของ deck/หน้าค้นหา — เงื่อนไขกรองและการจัดลำดับใกล้-ไกลอยู่ที่นี่ที่เดียว ห้ามเขียน query deck ซ้ำที่อื่น';


-- -----------------------------------------------------------------------------
-- mark_conversation_read — ทำเครื่องหมายว่าอ่านข้อความในห้องแล้ว
--
-- ต้องอัปเดต 2 ที่ให้ตรงกันเสมอ: read_at รายข้อความ กับตัวนับบนห้อง
-- ถ้าแยกไปทำในชั้น service จะมีวันที่อันหนึ่งสำเร็จอีกอันล้ม
-- แล้ว badge จะค้างเป็นเลขแดงที่กดยังไงก็ไม่หาย
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION mark_conversation_read(
  p_conversation_id uuid,
  p_reader_id       uuid
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  conv conversations%ROWTYPE;
BEGIN
  SELECT * INTO conv FROM conversations WHERE id = p_conversation_id FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'ไม่พบห้องแชท %', p_conversation_id
      USING ERRCODE = 'no_data_found';
  END IF;

  IF p_reader_id <> conv.initiator_id AND p_reader_id <> conv.owner_id THEN
    RAISE EXCEPTION 'ผู้ใช้ % ไม่ใช่คู่สนทนาของห้อง %', p_reader_id, p_conversation_id
      USING ERRCODE = 'insufficient_privilege';
  END IF;

  UPDATE messages
     SET read_at = now()
   WHERE conversation_id = p_conversation_id
     AND sender_id <> p_reader_id
     AND read_at IS NULL;

  IF p_reader_id = conv.initiator_id THEN
    UPDATE conversations
       SET initiator_unread_count = 0, initiator_last_read_at = now()
     WHERE id = p_conversation_id;
  ELSE
    UPDATE conversations
       SET owner_unread_count = 0, owner_last_read_at = now()
     WHERE id = p_conversation_id;
  END IF;
END;
$$;

COMMIT;
