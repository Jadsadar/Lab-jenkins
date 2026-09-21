-- =============================================================================
-- verify.sql — พิสูจน์ว่ากฎธุรกิจที่ฝังไว้ในฐานข้อมูลทำงานจริง
--
-- รันด้วย:
--   docker compose exec -T postgres psql -U petpaws -d petpaws -v ON_ERROR_STOP=1 < db/verify.sql
--
-- สคริปต์นี้สร้างข้อมูลทดสอบ ทดสอบ แล้วลบทิ้งทั้งหมด (ROLLBACK ตอนท้าย)
-- ฐานข้อมูลจริงจะไม่มีอะไรเปลี่ยน
--
-- ถ้ามีข้อไหนไม่ผ่าน สคริปต์จะหยุดพร้อมข้อความบอกว่าข้อไหน
-- =============================================================================

\set ON_ERROR_STOP on

-- =============================================================================
BEGIN;

DO $verify$
DECLARE
  u_somchai uuid;
  u_malee   uuid;
  pet_a     uuid;   -- ของสมชาย
  pet_b     uuid;   -- ของมาลี
  conv      uuid;
  u_outsider uuid;
  n         int;
  ok        boolean;
BEGIN
  RAISE NOTICE '--- เตรียมข้อมูลทดสอบ ---';

  INSERT INTO users (email, password_hash, display_name, location)
  VALUES ('somchai@test.local', 'argon2id$dummy', 'สมชาย', 'กรุงเทพมหานคร')
  RETURNING id INTO u_somchai;

  INSERT INTO users (email, password_hash, display_name, location)
  VALUES ('malee@test.local', 'argon2id$dummy', 'มาลี', 'เชียงใหม่')
  RETURNING id INTO u_malee;

  INSERT INTO users (email, password_hash, display_name)
  VALUES ('outsider@test.local', 'argon2id$dummy', 'คนนอก')
  RETURNING id INTO u_outsider;

  INSERT INTO pets (owner_id, name, species, age_months, sex, location)
  VALUES (u_somchai, 'ข้าวปั้น', 'dog', 18, 'male', 'กรุงเทพมหานคร')
  RETURNING id INTO pet_a;

  INSERT INTO pets (owner_id, name, species, age_months, sex, location)
  VALUES (u_malee, 'ส้มโอ', 'cat', 6, 'female', 'เชียงใหม่')
  RETURNING id INTO pet_b;

  -- ==========================================================================
  RAISE NOTICE '[1] อีเมลต้องไม่ซ้ำแบบไม่สนตัวพิมพ์เล็กใหญ่';
  BEGIN
    INSERT INTO users (email, password_hash, display_name)
    VALUES ('SOMCHAI@TEST.LOCAL', 'x', 'ปลอม');
    RAISE EXCEPTION 'ไม่ผ่าน [1]: สมัครอีเมลซ้ำด้วยตัวพิมพ์ใหญ่ได้';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE '    ผ่าน — ถูกปฏิเสธตามคาด';
  END;

  -- ==========================================================================
  RAISE NOTICE '[2] ห้ามปัดสัตว์ของตัวเอง';
  BEGIN
    INSERT INTO likes (user_id, pet_id) VALUES (u_somchai, pet_a);
    RAISE EXCEPTION 'ไม่ผ่าน [2]: กดถูกใจสัตว์ตัวเองได้';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE '    ผ่าน — ถูกปฏิเสธตามคาด';
  END;

  BEGIN
    INSERT INTO passes (user_id, pet_id) VALUES (u_somchai, pet_a);
    RAISE EXCEPTION 'ไม่ผ่าน [2b]: ปัดซ้ายสัตว์ตัวเองได้';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE '    ผ่าน — ปัดซ้ายก็ถูกปฏิเสธ';
  END;

  -- ==========================================================================
  RAISE NOTICE '[3] กดถูกใจแล้ว like_count ต้องขยับเอง';
  INSERT INTO likes (user_id, pet_id) VALUES (u_malee, pet_a);
  SELECT like_count INTO n FROM pets WHERE id = pet_a;
  IF n <> 1 THEN
    RAISE EXCEPTION 'ไม่ผ่าน [3]: like_count = % (ควรเป็น 1)', n;
  END IF;
  RAISE NOTICE '    ผ่าน — like_count = 1';

  RAISE NOTICE '[4] กดถูกใจซ้ำไม่ได้';
  BEGIN
    INSERT INTO likes (user_id, pet_id) VALUES (u_malee, pet_a);
    RAISE EXCEPTION 'ไม่ผ่าน [4]: กดถูกใจซ้ำได้';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE '    ผ่าน — ถูกปฏิเสธตามคาด';
  END;

  RAISE NOTICE '[5] ถอนถูกใจแล้ว like_count ต้องลดลง';
  DELETE FROM likes WHERE user_id = u_malee AND pet_id = pet_a;
  SELECT like_count INTO n FROM pets WHERE id = pet_a;
  IF n <> 0 THEN
    RAISE EXCEPTION 'ไม่ผ่าน [5]: like_count = % (ควรเป็น 0)', n;
  END IF;
  RAISE NOTICE '    ผ่าน — like_count = 0';
  INSERT INTO likes (user_id, pet_id) VALUES (u_malee, pet_a);

  -- ==========================================================================
  RAISE NOTICE '[6] owner_id ของห้องแชทต้องตรงกับเจ้าของสัตว์จริง (composite FK)';
  -- pet_a เป็นของสมชาย แต่แถวนี้อ้างว่ามาลีเป็นเจ้าของ
  -- ใช้คนนอกเป็นผู้ทักเพื่อให้ผ่าน CHECK initiator <> owner ไปก่อน
  -- จะได้พิสูจน์ว่า composite FK เป็นตัวปฏิเสธจริง ไม่ใช่ CHECK ตัวอื่นดักไว้
  BEGIN
    INSERT INTO conversations (pet_id, initiator_id, owner_id)
    VALUES (pet_a, u_outsider, u_malee);
    RAISE EXCEPTION 'ไม่ผ่าน [6]: สร้างห้องที่ owner_id ไม่ตรงกับเจ้าของสัตว์ได้';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE '    ผ่าน — composite FK ปฏิเสธ';
  END;

  -- ==========================================================================
  RAISE NOTICE '[7] ห้องแชทเปล่าต้องสร้างไม่ได้';
  BEGIN
    INSERT INTO conversations (pet_id, initiator_id, owner_id)
    VALUES (pet_a, u_malee, u_somchai);
    -- บังคับให้ constraint ที่ถูกเลื่อนไว้ทำงานทันทีโดยไม่ต้องรอ COMMIT จริง
    SET CONSTRAINTS conversations_require_first_message IMMEDIATE;
    RAISE EXCEPTION 'ไม่ผ่าน [7]: สร้างห้องแชทเปล่าได้';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE '    ผ่าน — ถูกปฏิเสธตามคาด';
  END;
  SET CONSTRAINTS conversations_require_first_message DEFERRED;

  -- ==========================================================================
  RAISE NOTICE '[8] ห้อง + ข้อความแรกพร้อมกัน ต้องผ่าน';
  INSERT INTO conversations (pet_id, initiator_id, owner_id)
  VALUES (pet_a, u_malee, u_somchai)
  RETURNING id INTO conv;

  INSERT INTO messages (conversation_id, sender_id, body)
  VALUES (conv, u_malee, 'สวัสดีค่ะ สนใจน้องข้าวปั้นค่ะ ยังหาบ้านอยู่ไหมคะ');
  RAISE NOTICE '    ผ่าน — สร้างห้องพร้อมข้อความแรกสำเร็จ';

  -- ==========================================================================
  RAISE NOTICE '[9] ตัวนับ unread ต้องขึ้นเฉพาะฝั่งผู้รับ';
  SELECT owner_unread_count INTO n FROM conversations WHERE id = conv;
  IF n <> 1 THEN
    RAISE EXCEPTION 'ไม่ผ่าน [9]: owner_unread_count = % (ควรเป็น 1)', n;
  END IF;
  SELECT initiator_unread_count INTO n FROM conversations WHERE id = conv;
  IF n <> 0 THEN
    RAISE EXCEPTION 'ไม่ผ่าน [9b]: initiator_unread_count = % (ควรเป็น 0)', n;
  END IF;
  RAISE NOTICE '    ผ่าน — เจ้าของ 1 / คนทัก 0';

  RAISE NOTICE '[10] last_message_preview ต้องอัปเดตเอง';
  SELECT last_message_preview IS NOT NULL INTO ok FROM conversations WHERE id = conv;
  IF NOT ok THEN
    RAISE EXCEPTION 'ไม่ผ่าน [10]: last_message_preview ว่าง';
  END IF;
  RAISE NOTICE '    ผ่าน';

  -- ==========================================================================
  RAISE NOTICE '[11] คนนอกส่งข้อความเข้าห้องไม่ได้';
  BEGIN
    INSERT INTO messages (conversation_id, sender_id, body)
    VALUES (conv, u_outsider, 'ขอแทรกหน่อย');
    RAISE EXCEPTION 'ไม่ผ่าน [11]: คนนอกส่งข้อความได้';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE '    ผ่าน — ถูกปฏิเสธตามคาด';
  END;

  -- ==========================================================================
  RAISE NOTICE '[12] mark_conversation_read ต้องล้างตัวนับ';
  PERFORM mark_conversation_read(conv, u_somchai);
  SELECT owner_unread_count INTO n FROM conversations WHERE id = conv;
  IF n <> 0 THEN
    RAISE EXCEPTION 'ไม่ผ่าน [12]: owner_unread_count = % (ควรเป็น 0)', n;
  END IF;
  SELECT count(*) INTO n FROM messages WHERE conversation_id = conv AND read_at IS NULL;
  IF n <> 0 THEN
    RAISE EXCEPTION 'ไม่ผ่าน [12b]: ยังมีข้อความที่ read_at ว่างอยู่ % ข้อความ', n;
  END IF;
  RAISE NOTICE '    ผ่าน — ตัวนับและ read_at ตรงกัน';

  -- ==========================================================================
  RAISE NOTICE '[13] deck ต้องไม่มีสัตว์ของตัวเอง และไม่มีตัวที่ปัดแล้ว';
  SELECT count(*) INTO n FROM deck_feed(u_somchai) WHERE owner_id = u_somchai;
  IF n <> 0 THEN
    RAISE EXCEPTION 'ไม่ผ่าน [13]: deck มีสัตว์ของตัวเอง % ตัว', n;
  END IF;

  -- มาลีถูกใจ pet_a ไปแล้วในข้อ [5] จึงต้องไม่เห็นอีก
  SELECT count(*) INTO n FROM deck_feed(u_malee) WHERE id = pet_a;
  IF n <> 0 THEN
    RAISE EXCEPTION 'ไม่ผ่าน [13b]: deck แสดงตัวที่เคยถูกใจไปแล้ว';
  END IF;

  -- สมชายยังไม่เคยปัด ส้มโอ จึงต้องเห็น
  SELECT count(*) INTO n FROM deck_feed(u_somchai) WHERE id = pet_b;
  IF n <> 1 THEN
    RAISE EXCEPTION 'ไม่ผ่าน [13c]: deck ไม่แสดงสัตว์ที่ควรแสดง (เจอ % แถว)', n;
  END IF;
  RAISE NOTICE '    ผ่าน — กรองครบทุกเงื่อนไข';

  -- ==========================================================================
  RAISE NOTICE '[14] เปลี่ยนสถานะเป็น adopted ต้องปิดห้องแชทอัตโนมัติ';
  UPDATE pets SET status = 'adopted', adopted_at = now() WHERE id = pet_a;

  SELECT status = 'closed' AND closed_reason = 'pet_adopted'
    INTO ok FROM conversations WHERE id = conv;
  IF NOT ok THEN
    RAISE EXCEPTION 'ไม่ผ่าน [14]: ห้องแชทไม่ได้ถูกปิด';
  END IF;
  RAISE NOTICE '    ผ่าน — ห้องถูกปิดพร้อมเหตุผล pet_adopted';

  RAISE NOTICE '[15] ห้องที่ปิดแล้วส่งข้อความใหม่ไม่ได้';
  BEGIN
    INSERT INTO messages (conversation_id, sender_id, body)
    VALUES (conv, u_malee, 'ยังอยู่ไหมคะ');
    RAISE EXCEPTION 'ไม่ผ่าน [15]: ส่งข้อความเข้าห้องที่ปิดแล้วได้';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE '    ผ่าน — ถูกปฏิเสธตามคาด';
  END;

  RAISE NOTICE '[16] สัตว์ที่ adopted ต้องหลุดจาก deck แต่ยังอยู่บนโปรไฟล์';
  SELECT count(*) INTO n FROM deck_feed(u_malee) WHERE id = pet_a;
  IF n <> 0 THEN
    RAISE EXCEPTION 'ไม่ผ่าน [16]: สัตว์ที่ adopted ยังอยู่ใน deck';
  END IF;
  SELECT count(*) INTO n FROM pets WHERE owner_id = u_somchai AND deleted_at IS NULL;
  IF n <> 1 THEN
    RAISE EXCEPTION 'ไม่ผ่าน [16b]: สัตว์หายไปจากโปรไฟล์เจ้าของ';
  END IF;
  RAISE NOTICE '    ผ่าน — หลุดจาก deck แต่ยังอยู่บนโปรไฟล์';

  RAISE NOTICE '[17] adopted ต้องมี adopted_at เสมอ';
  BEGIN
    UPDATE pets SET status = 'adopted', adopted_at = NULL WHERE id = pet_b;
    RAISE EXCEPTION 'ไม่ผ่าน [17]: ตั้ง adopted โดยไม่มี adopted_at ได้';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE '    ผ่าน — ถูกปฏิเสธตามคาด';
  END;

  -- ==========================================================================
  RAISE NOTICE '[18] บล็อกแล้วต้องหายจาก deck ทั้งสองทาง';
  INSERT INTO blocks (blocker_id, blocked_id) VALUES (u_malee, u_somchai);

  SELECT count(*) INTO n FROM deck_feed(u_somchai) WHERE owner_id = u_malee;
  IF n <> 0 THEN
    RAISE EXCEPTION 'ไม่ผ่าน [18]: คนที่ถูกบล็อกยังเห็นสัตว์ของคนบล็อก';
  END IF;
  RAISE NOTICE '    ผ่าน — บล็อกมีผลสองทาง';

  RAISE NOTICE '[19] บล็อกตัวเองไม่ได้';
  BEGIN
    INSERT INTO blocks (blocker_id, blocked_id) VALUES (u_malee, u_malee);
    RAISE EXCEPTION 'ไม่ผ่าน [19]: บล็อกตัวเองได้';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE '    ผ่าน — ถูกปฏิเสธตามคาด';
  END;

  -- ==========================================================================
  RAISE NOTICE '[20] รายงานต้องระบุเป้าหมายพอดี 1 อย่าง';
  BEGIN
    INSERT INTO reports (reporter_id, reported_pet_id, reported_user_id, reason)
    VALUES (u_malee, pet_a, u_somchai, 'spam');
    RAISE EXCEPTION 'ไม่ผ่าน [20]: ระบุเป้าหมาย 2 อย่างพร้อมกันได้';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE '    ผ่าน — ถูกปฏิเสธตามคาด';
  END;

  BEGIN
    INSERT INTO reports (reporter_id, reason) VALUES (u_malee, 'spam');
    RAISE EXCEPTION 'ไม่ผ่าน [20b]: ไม่ระบุเป้าหมายเลยก็ยังสร้างได้';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE '    ผ่าน — ถูกปฏิเสธตามคาด';
  END;

  RAISE NOTICE '[21] รายงานแล้ว report_count ต้องขยับ และรายงานซ้ำไม่ได้';
  INSERT INTO reports (reporter_id, reported_pet_id, reason)
  VALUES (u_malee, pet_a, 'fake_info');

  SELECT report_count INTO n FROM pets WHERE id = pet_a;
  IF n <> 1 THEN
    RAISE EXCEPTION 'ไม่ผ่าน [21]: report_count = % (ควรเป็น 1)', n;
  END IF;

  BEGIN
    INSERT INTO reports (reporter_id, reported_pet_id, reason)
    VALUES (u_malee, pet_a, 'spam');
    RAISE EXCEPTION 'ไม่ผ่าน [21b]: รายงานประกาศเดิมซ้ำได้';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE '    ผ่าน — report_count = 1 และรายงานซ้ำไม่ได้';
  END;

  -- ==========================================================================
  RAISE NOTICE '[22] ข้อความยาวเกิน 2000 ตัวอักษรต้องถูกปฏิเสธ';
  DECLARE
    conv2 uuid;
  BEGIN
    INSERT INTO conversations (pet_id, initiator_id, owner_id)
    VALUES (pet_b, u_somchai, u_malee)
    RETURNING id INTO conv2;

    BEGIN
      INSERT INTO messages (conversation_id, sender_id, body)
      VALUES (conv2, u_somchai, repeat('ก', 2001));
      RAISE EXCEPTION 'ไม่ผ่าน [22]: ส่งข้อความยาวเกินกำหนดได้';
    EXCEPTION WHEN check_violation THEN
      RAISE NOTICE '    ผ่าน — ถูกปฏิเสธตามคาด';
    END;

    INSERT INTO messages (conversation_id, sender_id, body)
    VALUES (conv2, u_somchai, 'สนใจน้องส้มโอครับ');
  END;

  RAISE NOTICE '[23] 1 คน ทักเรื่องสัตว์ตัวเดิมได้ห้องเดียว';
  BEGIN
    INSERT INTO conversations (pet_id, initiator_id, owner_id)
    VALUES (pet_b, u_somchai, u_malee);
    RAISE EXCEPTION 'ไม่ผ่าน [23]: สร้างห้องซ้ำสำหรับสัตว์ตัวเดิมได้';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE '    ผ่าน — ถูกปฏิเสธตามคาด';
  END;

  RAISE NOTICE '';
  RAISE NOTICE '=========================================';
  RAISE NOTICE '  ผ่านครบทั้ง 23 ข้อ';
  RAISE NOTICE '=========================================';
END
$verify$;

-- ยกเลิกทุกอย่าง ไม่ทิ้งข้อมูลทดสอบไว้ในฐานข้อมูล
ROLLBACK;
