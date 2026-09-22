-- =============================================================================
-- 002_test_accounts.sql — 10 บัญชีทดสอบ ครอบคลุมทุก edge case ที่ schema รองรับ
--
-- รันด้วย:
--   docker compose exec -T postgres psql -U petpaws -d petpaws -v ON_ERROR_STOP=1 < db/seeds/002_test_accounts.sql
--
-- รันซ้ำได้ไม่พัง (ล้างบัญชี @petpaws.test เดิมก่อนเสมอ) — ใช้โดเมนแยกจาก
-- 001_dev_seed.sql (@petpaws.dev) เพื่อให้ล้าง/รันแยกจากกันได้อิสระ
--
-- password_hash เป็นค่าสมมติเหมือน 001 — ล็อกอินผ่าน API ด้วยบัญชีนี้ไม่ได้
-- ห้ามนำไฟล์นี้ไปรันบน production
--
-- สิ่งที่ตั้งใจให้ข้อมูลชุดนี้ทดสอบได้ (เทียบกับแต่ละบัญชี):
--   1. testuser01  กรุงเทพฯ    เจ้าของ 2 ตัว (available) + มี contacts/traits ครบ
--   2. testuser02  เชียงใหม่   เจ้าของ 2 ตัว (1 available, 1 pending)
--   3. testuser03  กรุงเทพฯ    ผู้รับเลี้ยงล้วน ไม่มีประกาศ — ถูกใจ/ปัดผ่านมาแล้วหลายตัว
--   4. testuser04  ภูเก็ต      ผู้รับเลี้ยงล้วน — ทดสอบ proximity_rank ข้ามภาคจาก testuser01
--   5. testuser05  เชียงราย    เจ้าของ 1 ตัว — ภาคเหนือเดียวกับ testuser02 แต่คนละจังหวัด
--                              (ทดสอบ rank 1 "ภาคเดียวกัน" ให้ testuser02 เห็น)
--   6. testuser06  สงขลา       เจ้าของ 1 ตัว ที่ถูกรายงานแล้ว 2 ครั้ง (ทดสอบ report_count)
--   7. testuser07  นนทบุรี     ผู้รับเลี้ยง — บล็อก testuser08 (ทดสอบบล็อกสองทาง + ปิดห้องแชท)
--   8. testuser08  ระยอง       เจ้าของ 1 ตัว ที่ถูก testuser07 บล็อก
--   9. testuser09  อุดรธานี    เจ้าของ 1 ตัว ที่ "ได้บ้านแล้ว" (adopted) — ทดสอบว่าหลุดจาก deck
--                              แต่ยังอยู่บนโปรไฟล์เจ้าของ
--  10. testuser10  ขอนแก่น     บัญชีถูกระงับ (is_suspended) — ทดสอบว่าประกาศของเขาต้อง
--                              หายจาก deck ของทุกคนแม้จะเป็น available ก็ตาม
-- =============================================================================

\set ON_ERROR_STOP on

BEGIN;

-- ---------- ล้างข้อมูลเดิม ----------
DELETE FROM messages       WHERE conversation_id IN (
  SELECT c.id FROM conversations c
  JOIN users u ON u.id = c.initiator_id WHERE u.email LIKE '%@petpaws.test');
DELETE FROM conversations  WHERE initiator_id IN (SELECT id FROM users WHERE email LIKE '%@petpaws.test')
                              OR owner_id     IN (SELECT id FROM users WHERE email LIKE '%@petpaws.test');
DELETE FROM reports        WHERE reporter_id IN (SELECT id FROM users WHERE email LIKE '%@petpaws.test')
                              OR reported_pet_id IN (
                                SELECT p.id FROM pets p JOIN users u ON u.id = p.owner_id
                                WHERE u.email LIKE '%@petpaws.test');
DELETE FROM blocks         WHERE blocker_id  IN (SELECT id FROM users WHERE email LIKE '%@petpaws.test')
                              OR blocked_id  IN (SELECT id FROM users WHERE email LIKE '%@petpaws.test');
DELETE FROM likes          WHERE user_id     IN (SELECT id FROM users WHERE email LIKE '%@petpaws.test');
DELETE FROM passes         WHERE user_id     IN (SELECT id FROM users WHERE email LIKE '%@petpaws.test');
DELETE FROM pet_traits     WHERE pet_id IN (
  SELECT p.id FROM pets p JOIN users u ON u.id = p.owner_id WHERE u.email LIKE '%@petpaws.test');
DELETE FROM pet_media      WHERE pet_id IN (
  SELECT p.id FROM pets p JOIN users u ON u.id = p.owner_id WHERE u.email LIKE '%@petpaws.test');
DELETE FROM pets           WHERE owner_id IN (SELECT id FROM users WHERE email LIKE '%@petpaws.test');
DELETE FROM user_traits    WHERE user_id  IN (SELECT id FROM users WHERE email LIKE '%@petpaws.test');
DELETE FROM user_contacts  WHERE user_id  IN (SELECT id FROM users WHERE email LIKE '%@petpaws.test');
DELETE FROM device_tokens  WHERE user_id  IN (SELECT id FROM users WHERE email LIKE '%@petpaws.test');
DELETE FROM refresh_tokens WHERE user_id  IN (SELECT id FROM users WHERE email LIKE '%@petpaws.test');
DELETE FROM users          WHERE email LIKE '%@petpaws.test';


DO $seed$
DECLARE
  pw text := '$argon2id$v=19$m=65536,t=3,p=4$c2VlZHNhbHRzZWVkc2E$UExBQ0VIT0xERVJfTk9UX0FfUkVBTF9IQVNI';

  u01 uuid; u02 uuid; u03 uuid; u04 uuid; u05 uuid;
  u06 uuid; u07 uuid; u08 uuid; u09 uuid; u10 uuid;

  pet01a uuid; pet01b uuid; pet02a uuid; pet02b uuid; pet05 uuid;
  pet06 uuid; pet08 uuid; pet09 uuid; pet10 uuid;

  conv uuid;

  -- helper: ดึง id ของแท็กจาก slug ให้อ่านโค้ดง่ายขึ้น
  t_energetic uuid; t_chill uuid; t_affectionate uuid; t_independent uuid;
  t_talkative uuid; t_quiet uuid; t_social uuid; t_kid_friendly uuid;
  t_foodie uuid; t_tidy uuid;
BEGIN
  SELECT id INTO t_energetic    FROM traits WHERE slug = 'energetic';
  SELECT id INTO t_chill        FROM traits WHERE slug = 'chill';
  SELECT id INTO t_affectionate FROM traits WHERE slug = 'affectionate';
  SELECT id INTO t_independent  FROM traits WHERE slug = 'independent';
  SELECT id INTO t_talkative    FROM traits WHERE slug = 'talkative';
  SELECT id INTO t_quiet        FROM traits WHERE slug = 'quiet';
  SELECT id INTO t_social       FROM traits WHERE slug = 'social';
  SELECT id INTO t_kid_friendly FROM traits WHERE slug = 'kid_friendly';
  SELECT id INTO t_foodie       FROM traits WHERE slug = 'foodie';
  SELECT id INTO t_tidy         FROM traits WHERE slug = 'tidy';

  -- ==========================================================================
  -- ผู้ใช้ 10 คน
  -- ==========================================================================
  INSERT INTO users (username, email, password_hash, display_name, bio, location, home_type, email_verified_at)
  VALUES ('testuser01', 'testuser01@petpaws.test', pw, 'ทดสอบ หนึ่ง',
          'เจ้าของหลายตัว มีข้อมูลครบทุกช่อง ใช้ทดสอบหน้าโปรไฟล์แบบเต็ม',
          'กรุงเทพมหานคร', 'detached_house', now())
  RETURNING id INTO u01;

  INSERT INTO users (username, email, password_hash, display_name, bio, location, home_type, email_verified_at)
  VALUES ('testuser02', 'testuser02@petpaws.test', pw, 'ทดสอบ สอง',
          'มีทั้งประกาศที่เปิดรับและกำลังคุยอยู่ (pending)', 'เชียงใหม่', 'condo', now())
  RETURNING id INTO u02;

  INSERT INTO users (username, email, password_hash, display_name, bio, location)
  VALUES ('testuser03', 'testuser03@petpaws.test', pw, 'ทดสอบ สาม',
          'ผู้รับเลี้ยงล้วน ไม่มีประกาศของตัวเอง', 'กรุงเทพมหานคร')
  RETURNING id INTO u03;

  INSERT INTO users (username, email, password_hash, display_name, bio, location)
  VALUES ('testuser04', 'testuser04@petpaws.test', pw, 'ทดสอบ สี่',
          'อยู่คนละภาคกับส่วนใหญ่ ใช้ทดสอบ proximity rank 2', 'ภูเก็ต')
  RETURNING id INTO u04;

  INSERT INTO users (username, email, password_hash, display_name, bio, location)
  VALUES ('testuser05', 'testuser05@petpaws.test', pw, 'ทดสอบ ห้า',
          'อยู่ภาคเหนือเดียวกับทดสอบสอง แต่คนละจังหวัด', 'เชียงราย')
  RETURNING id INTO u05;

  INSERT INTO users (username, email, password_hash, display_name, bio, location)
  VALUES ('testuser06', 'testuser06@petpaws.test', pw, 'ทดสอบ หก',
          'ประกาศของคนนี้จะถูกรายงาน 2 ครั้ง', 'สงขลา')
  RETURNING id INTO u06;

  INSERT INTO users (username, email, password_hash, display_name, bio, location)
  VALUES ('testuser07', 'testuser07@petpaws.test', pw, 'ทดสอบ เจ็ด',
          'จะกดบล็อกทดสอบแปด', 'นนทบุรี')
  RETURNING id INTO u07;

  INSERT INTO users (username, email, password_hash, display_name, bio, location)
  VALUES ('testuser08', 'testuser08@petpaws.test', pw, 'ทดสอบ แปด',
          'ถูกทดสอบเจ็ดบล็อก', 'ระยอง')
  RETURNING id INTO u08;

  INSERT INTO users (username, email, password_hash, display_name, bio, location)
  VALUES ('testuser09', 'testuser09@petpaws.test', pw, 'ทดสอบ เก้า',
          'ประกาศของคนนี้จะถูกทำเครื่องหมายว่าได้บ้านแล้ว', 'อุดรธานี')
  RETURNING id INTO u09;

  -- บัญชีถูกระงับ — ทดสอบว่าประกาศของบัญชีนี้ต้องหายจาก deck ของทุกคน
  -- แม้ pets.status จะเป็น available ก็ตาม (deck_feed กรอง u.is_suspended ด้วย)
  INSERT INTO users (username, email, password_hash, display_name, bio, location, is_suspended)
  VALUES ('testuser10', 'testuser10@petpaws.test', pw, 'ทดสอบ สิบ',
          'บัญชีนี้ถูกระงับ ใช้ทดสอบว่า deck กรองออกจริง', 'ขอนแก่น', true)
  RETURNING id INTO u10;

  -- ---------- ข้อมูลติดต่อ + นิสัยผู้ใช้ (migration 009) เฉพาะบางบัญชี ----------
  INSERT INTO user_contacts (user_id, phone, line_id, fb_name)
  VALUES (u01, '0812345678', 'test_line01', 'ทดสอบ หนึ่ง');

  INSERT INTO user_traits (user_id, trait_id) VALUES
    (u01, t_quiet), (u01, t_kid_friendly),
    (u03, t_energetic), (u03, t_social);

  -- ==========================================================================
  -- ประกาศ
  -- ==========================================================================

  -- testuser01 — 2 ตัว เปิดรับทั้งคู่
  INSERT INTO pets (owner_id, name, species, breed, age_months, sex, size,
                    vaccinated, neutered, weight_kg, description, location, created_at)
  VALUES (u01, 'ปลาทู', 'dog', 'พันทาง', 10, 'male', 'small', true, false, 6.50,
          'ปลาทูเป็นน้องหมาตัวเล็ก พลังงานเยอะมาก ชอบวิ่งเล่นทั้งวัน',
          'กรุงเทพมหานคร', now() - interval '2 hours')
  RETURNING id INTO pet01a;

  INSERT INTO pets (owner_id, name, species, breed, age_months, sex, size,
                    vaccinated, neutered, weight_kg, description, location, created_at)
  VALUES (u01, 'มะลิ', 'cat', 'วิเชียรมาศ', 30, 'female', 'small', true, true, 3.80,
          'มะลิเป็นแมวไทยแท้ นิสัยรักอิสระ ไม่ค่อยติดคนแต่ไม่ดุ',
          'กรุงเทพมหานคร', now() - interval '5 days')
  RETURNING id INTO pet01b;

  INSERT INTO pet_media (pet_id, storage_key, url, sort_order) VALUES
    (pet01a, 'pets/test/pet01a-1.jpg', 'https://picsum.photos/seed/test01a/800/1000', 0),
    (pet01b, 'pets/test/pet01b-1.jpg', 'https://picsum.photos/seed/test01b/800/1000', 0);

  INSERT INTO pet_traits (pet_id, trait_id) VALUES
    (pet01a, t_energetic), (pet01a, t_kid_friendly),
    (pet01b, t_independent), (pet01b, t_chill);

  -- testuser02 — 1 ตัวเปิดรับ + 1 ตัวกำลังคุยอยู่ (pending)
  INSERT INTO pets (owner_id, name, species, breed, age_months, sex, size,
                    vaccinated, neutered, weight_kg, description, location, created_at)
  VALUES (u02, 'ข้าวหอม', 'dog', 'ปอมเมอเรเนียนผสม', 8, 'female', 'small',
          true, false, 2.90, 'ข้าวหอมเสียงดัง ช่างคุยมาก ชอบทักทายทุกคน',
          'เชียงใหม่', now() - interval '1 day')
  RETURNING id INTO pet02a;

  INSERT INTO pets (owner_id, name, species, breed, age_months, sex, size,
                    vaccinated, neutered, description, location, status, created_at)
  VALUES (u02, 'ดำ', 'cat', 'พันทาง', 18, 'male', 'medium',
          true, true, 'ดำกำลังคุยกับผู้สนใจอยู่ ยังไม่ปิดรับ',
          'เชียงใหม่', 'pending', now() - interval '8 days')
  RETURNING id INTO pet02b;

  INSERT INTO pet_media (pet_id, storage_key, url, sort_order) VALUES
    (pet02a, 'pets/test/pet02a-1.jpg', 'https://picsum.photos/seed/test02a/800/1000', 0),
    (pet02b, 'pets/test/pet02b-1.jpg', 'https://picsum.photos/seed/test02b/800/1000', 0);

  INSERT INTO pet_traits (pet_id, trait_id) VALUES
    (pet02a, t_talkative), (pet02a, t_social);

  -- testuser05 — เชียงราย (ภาคเหนือเดียวกับ testuser02)
  INSERT INTO pets (owner_id, name, species, breed, age_months, sex, size,
                    vaccinated, neutered, description, location, created_at)
  VALUES (u05, 'เต้าหู้', 'rabbit', 'ล็อบเอียร์', 5, 'male', 'small',
          false, false, 'เต้าหู้เป็นกระต่ายตัวเล็ก เงียบ ๆ ไม่ค่อยส่งเสียง',
          'เชียงราย', now() - interval '3 hours')
  RETURNING id INTO pet05;

  INSERT INTO pet_media (pet_id, storage_key, url, sort_order) VALUES
    (pet05, 'pets/test/pet05-1.jpg', 'https://picsum.photos/seed/test05/800/1000', 0);

  INSERT INTO pet_traits (pet_id, trait_id) VALUES (pet05, t_quiet), (pet05, t_tidy);

  -- testuser06 — สงขลา (จะถูกรายงาน)
  INSERT INTO pets (owner_id, name, species, breed, age_months, sex, size,
                    vaccinated, neutered, description, location, created_at)
  VALUES (u06, 'แจ๊ค', 'dog', 'พันทาง', 24, 'male', 'medium',
          false, false, 'ประกาศนี้ถูกใช้ทดสอบระบบรายงาน',
          'สงขลา', now() - interval '4 days')
  RETURNING id INTO pet06;

  INSERT INTO pet_media (pet_id, storage_key, url, sort_order) VALUES
    (pet06, 'pets/test/pet06-1.jpg', 'https://picsum.photos/seed/test06/800/1000', 0);

  -- testuser08 — ระยอง (จะถูกบล็อกโดย testuser07)
  INSERT INTO pets (owner_id, name, species, breed, age_months, sex, size,
                    vaccinated, neutered, description, location, created_at)
  VALUES (u08, 'บุปผา', 'cat', 'เปอร์เซีย', 14, 'female', 'medium',
          true, true, 'บุปผาสายกิน ชอบทำความสะอาดตัวเองอยู่เสมอ',
          'ระยอง', now() - interval '6 hours')
  RETURNING id INTO pet08;

  INSERT INTO pet_media (pet_id, storage_key, url, sort_order) VALUES
    (pet08, 'pets/test/pet08-1.jpg', 'https://picsum.photos/seed/test08/800/1000', 0);

  INSERT INTO pet_traits (pet_id, trait_id) VALUES (pet08, t_foodie), (pet08, t_tidy);

  -- testuser09 — อุดรธานี (ได้บ้านแล้ว)
  INSERT INTO pets (owner_id, name, species, breed, age_months, sex, size,
                    vaccinated, neutered, description, location,
                    status, adopted_at, created_at)
  VALUES (u09, 'โชคดี', 'dog', 'พันทาง', 20, 'male', 'medium',
          true, true, 'โชคดีได้บ้านใหม่แล้ว ใช้ทดสอบว่าหลุดจาก deck แต่ยังอยู่บนโปรไฟล์',
          'อุดรธานี', 'adopted', now() - interval '1 day', now() - interval '20 days')
  RETURNING id INTO pet09;

  INSERT INTO pet_media (pet_id, storage_key, url, sort_order) VALUES
    (pet09, 'pets/test/pet09-1.jpg', 'https://picsum.photos/seed/test09/800/1000', 0);

  -- testuser10 — ขอนแก่น (เจ้าของถูกระงับบัญชี)
  INSERT INTO pets (owner_id, name, species, breed, age_months, sex, size,
                    vaccinated, neutered, description, location, created_at)
  VALUES (u10, 'ระวัง', 'dog', 'พันทาง', 12, 'male', 'medium',
          false, false, 'ประกาศนี้ status เป็น available ปกติ แต่เจ้าของถูกระงับบัญชี '
          '— ต้องไม่โผล่ใน deck ของใครเลย',
          'ขอนแก่น', now() - interval '2 days')
  RETURNING id INTO pet10;

  INSERT INTO pet_media (pet_id, storage_key, url, sort_order) VALUES
    (pet10, 'pets/test/pet10-1.jpg', 'https://picsum.photos/seed/test10/800/1000', 0);

  -- ==========================================================================
  -- การปัด — testuser03 กับ testuser04 ปัดไปหลายตัวแล้ว (ผู้รับเลี้ยงล้วน)
  -- ==========================================================================
  INSERT INTO likes (user_id, pet_id) VALUES
    (u03, pet01a), (u03, pet02a), (u03, pet05);
  INSERT INTO passes (user_id, pet_id) VALUES
    (u03, pet06), (u03, pet08);

  INSERT INTO likes (user_id, pet_id) VALUES (u04, pet01b);
  INSERT INTO passes (user_id, pet_id) VALUES (u04, pet02a);

  -- ==========================================================================
  -- แชท — 2 ห้อง สถานะต่างกัน (ยังไม่อ่าน / อ่านแล้ว)
  -- ==========================================================================
  INSERT INTO conversations (pet_id, initiator_id, owner_id)
  VALUES (pet01a, u03, u01)
  RETURNING id INTO conv;

  INSERT INTO messages (conversation_id, sender_id, body, created_at) VALUES
    (conv, u03, 'สวัสดีค่ะ สนใจน้องปลาทูค่ะ พาไปวิ่งเล่นได้ทุกวันไหมคะ',
     now() - interval '3 hours'),
    (conv, u01, 'ได้เลยครับ ปลาทูพลังเยอะมากต้องพาออกกำลังทุกวันอยู่แล้ว',
     now() - interval '2 hours 40 minutes');
  -- จงใจไม่เรียก mark_conversation_read เลยสักฝั่ง — ห้องนี้จึงมี unread ค้างอยู่
  -- ทั้งสองฝั่ง (testuser01 ยังไม่อ่านข้อความแรกของ testuser03, และ testuser03
  -- ยังไม่อ่านข้อความตอบกลับ) ต่างจากห้องที่สองด้านล่างที่อ่านแล้วฝั่งเดียว

  INSERT INTO conversations (pet_id, initiator_id, owner_id)
  VALUES (pet02b, u04, u02)
  RETURNING id INTO conv;

  INSERT INTO messages (conversation_id, sender_id, body, created_at) VALUES
    (conv, u04, 'น้องดำยังหาบ้านอยู่ไหมคะ', now() - interval '2 days'),
    (conv, u02, 'ตอนนี้มีคนคุยอยู่คนนึงแล้วครับ รอผลอยู่นะครับ',
     now() - interval '1 day 20 hours');
  PERFORM mark_conversation_read(conv, u04);  -- ห้องนี้อ่านแล้วทั้งคู่

  -- ==========================================================================
  -- รายงาน — testuser06 ถูกรายงาน 2 ครั้งจากคนละคน (ทดสอบ report_count + unique)
  -- ==========================================================================
  INSERT INTO reports (reporter_id, reported_pet_id, reason, detail) VALUES
    (u03, pet06, 'fake_info', 'ข้อมูลดูไม่น่าเชื่อถือ'),
    (u04, pet06, 'spam', 'โพสต์ซ้ำหลายรอบ');

  -- ==========================================================================
  -- บล็อก — testuser07 บล็อก testuser08 (ต้องปิดห้องแชทถ้ามี + กันเห็นกันใน deck)
  -- ==========================================================================
  INSERT INTO blocks (blocker_id, blocked_id, reason)
  VALUES (u07, u08, 'ทักมาด้วยข้อความไม่สุภาพ');

  RAISE NOTICE '';
  RAISE NOTICE '========================================================';
  RAISE NOTICE '  สร้างบัญชีทดสอบ 10 บัญชีเรียบร้อย (โดเมน @petpaws.test)';
  RAISE NOTICE '  ประกาศ 9 รายการ / แชท 2 ห้อง / รายงาน 2 ครั้ง / บล็อก 1 คู่';
  RAISE NOTICE '  หมายเหตุ: password_hash เป็นค่าสมมติ ล็อกอินผ่าน API ไม่ได้';
  RAISE NOTICE '========================================================';
END
$seed$;

COMMIT;

-- ---------- สรุปผล ----------
SELECT 'users (test)'    AS ตาราง, count(*) AS จำนวน FROM users WHERE email LIKE '%@petpaws.test'
UNION ALL SELECT 'pets',          count(*) FROM pets p JOIN users u ON u.id=p.owner_id WHERE u.email LIKE '%@petpaws.test'
UNION ALL SELECT 'pet_media',     count(*) FROM pet_media pm JOIN pets p ON p.id=pm.pet_id JOIN users u ON u.id=p.owner_id WHERE u.email LIKE '%@petpaws.test'
UNION ALL SELECT 'pet_traits',    count(*) FROM pet_traits pt JOIN pets p ON p.id=pt.pet_id JOIN users u ON u.id=p.owner_id WHERE u.email LIKE '%@petpaws.test'
UNION ALL SELECT 'user_contacts', count(*) FROM user_contacts uc JOIN users u ON u.id=uc.user_id WHERE u.email LIKE '%@petpaws.test'
UNION ALL SELECT 'user_traits',   count(*) FROM user_traits ut JOIN users u ON u.id=ut.user_id WHERE u.email LIKE '%@petpaws.test'
UNION ALL SELECT 'likes',         count(*) FROM likes l JOIN users u ON u.id=l.user_id WHERE u.email LIKE '%@petpaws.test'
UNION ALL SELECT 'passes',        count(*) FROM passes pa JOIN users u ON u.id=pa.user_id WHERE u.email LIKE '%@petpaws.test'
UNION ALL SELECT 'conversations', count(*) FROM conversations c JOIN users u ON u.id=c.initiator_id WHERE u.email LIKE '%@petpaws.test'
UNION ALL SELECT 'messages',      count(*) FROM messages m JOIN conversations c ON c.id=m.conversation_id JOIN users u ON u.id=c.initiator_id WHERE u.email LIKE '%@petpaws.test'
UNION ALL SELECT 'reports',       count(*) FROM reports r JOIN users u ON u.id=r.reporter_id WHERE u.email LIKE '%@petpaws.test'
UNION ALL SELECT 'blocks',        count(*) FROM blocks b JOIN users u ON u.id=b.blocker_id WHERE u.email LIKE '%@petpaws.test';
