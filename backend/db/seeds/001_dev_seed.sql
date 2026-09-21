-- =============================================================================
-- 001_dev_seed.sql — ข้อมูลตัวอย่างสำหรับพัฒนา
--
-- รันด้วย:
--   docker compose exec -T postgres psql -U petpaws -d petpaws -v ON_ERROR_STOP=1 < db/seeds/001_dev_seed.sql
--
-- รันซ้ำได้ไม่พัง (ล้างข้อมูลตัวอย่างเดิมก่อนเสมอ)
--
-- ข้อควรรู้เรื่องรหัสผ่าน:
-- ค่า password_hash ในไฟล์นี้เป็น "ค่าสมมติ" ที่มีรูปแบบถูกต้องแต่ไม่ได้แฮชมาจากรหัสผ่านจริง
-- จึงล็อกอินผ่าน API ด้วยบัญชีเหล่านี้ไม่ได้ — ใช้สำหรับทดสอบ query และ UI เท่านั้น
--
-- เมื่อสร้าง auth module ใน NestJS แล้ว ให้ generate ค่าแฮชจริงด้วย argon2
-- แล้วแทนค่าตัวแปร pw ด้านล่าง หรือสมัครสมาชิกผ่าน POST /auth/register แทน
--
-- ห้ามนำไฟล์นี้ไปรันบน production
-- =============================================================================

\set ON_ERROR_STOP on

BEGIN;

-- ---------- ล้างข้อมูลตัวอย่างเดิม ----------
-- เรียงลำดับตามความสัมพันธ์ ลูกก่อนพ่อแม่ เพราะบาง FK เป็น RESTRICT
DELETE FROM messages       WHERE conversation_id IN (
  SELECT c.id FROM conversations c
  JOIN users u ON u.id = c.initiator_id WHERE u.email LIKE '%@petpaws.dev');
DELETE FROM conversations  WHERE initiator_id IN (SELECT id FROM users WHERE email LIKE '%@petpaws.dev')
                              OR owner_id     IN (SELECT id FROM users WHERE email LIKE '%@petpaws.dev');
DELETE FROM reports        WHERE reporter_id IN (SELECT id FROM users WHERE email LIKE '%@petpaws.dev');
DELETE FROM blocks         WHERE blocker_id  IN (SELECT id FROM users WHERE email LIKE '%@petpaws.dev');
DELETE FROM likes          WHERE user_id     IN (SELECT id FROM users WHERE email LIKE '%@petpaws.dev');
DELETE FROM passes         WHERE user_id     IN (SELECT id FROM users WHERE email LIKE '%@petpaws.dev');
DELETE FROM pet_traits     WHERE pet_id IN (
  SELECT p.id FROM pets p JOIN users u ON u.id = p.owner_id WHERE u.email LIKE '%@petpaws.dev');
DELETE FROM pet_media      WHERE pet_id IN (
  SELECT p.id FROM pets p JOIN users u ON u.id = p.owner_id WHERE u.email LIKE '%@petpaws.dev');
DELETE FROM pets           WHERE owner_id IN (SELECT id FROM users WHERE email LIKE '%@petpaws.dev');
DELETE FROM device_tokens  WHERE user_id  IN (SELECT id FROM users WHERE email LIKE '%@petpaws.dev');
DELETE FROM refresh_tokens WHERE user_id  IN (SELECT id FROM users WHERE email LIKE '%@petpaws.dev');
DELETE FROM users          WHERE email LIKE '%@petpaws.dev';


DO $seed$
DECLARE
  -- ค่าสมมติที่มีรูปแบบของ argon2id แต่ล็อกอินไม่ได้จริง (ดูหมายเหตุด้านบน)
  pw  text := '$argon2id$v=19$m=65536,t=3,p=4$c2VlZHNhbHRzZWVkc2E$UExBQ0VIT0xERVJfTk9UX0FfUkVBTF9IQVNI';
  somchai uuid; malee uuid; nattapong uuid; ploy uuid;
  khaopun uuid; somo uuid; mameung uuid; toffee uuid; latte uuid;
  conv uuid;
BEGIN
  -- ---------- ผู้ใช้ ----------
  INSERT INTO users (email, password_hash, display_name, bio, location, email_verified_at)
  VALUES ('somchai@petpaws.dev', pw, 'สมชาย ใจดี',
          'เลี้ยงหมามา 10 ปี มีบ้านมีสวน ยินดีให้คำปรึกษาคนเลี้ยงมือใหม่',
          'กรุงเทพมหานคร', now())
  RETURNING id INTO somchai;

  INSERT INTO users (email, password_hash, display_name, bio, location, email_verified_at)
  VALUES ('malee@petpaws.dev', pw, 'มาลี สดใส',
          'อาสาสมัครช่วยแมวจร หาบ้านให้น้องมาแล้วกว่า 30 ตัว',
          'เชียงใหม่', now())
  RETURNING id INTO malee;

  INSERT INTO users (email, password_hash, display_name, bio, location, email_verified_at)
  VALUES ('nattapong@petpaws.dev', pw, 'ณัฐพงศ์ พร้อมรับ',
          'อยากได้เพื่อนสักตัวไว้วิ่งด้วยกันตอนเช้า', 'กรุงเทพมหานคร', now())
  RETURNING id INTO nattapong;

  INSERT INTO users (email, password_hash, display_name, bio, location)
  VALUES ('ploy@petpaws.dev', pw, 'พลอย รักสัตว์',
          'อยู่คอนโด มองหาน้องแมวตัวเล็ก ๆ', 'ภูเก็ต')
  RETURNING id INTO ploy;

  -- ---------- ประกาศของสมชาย ----------
  INSERT INTO pets (owner_id, name, species, breed, age_months, sex, size,
                    vaccinated, neutered, weight_kg, description, location, created_at)
  VALUES (somchai, 'ข้าวปั้น', 'dog', 'พันทาง', 18, 'male', 'medium',
          true, true, 12.50,
          'ข้าวปั้นเป็นน้องหมาที่เก็บมาจากข้างถนนตอนยังเล็ก ๆ ตอนนี้แข็งแรงดีมาก '
          'ฉีดวัคซีนครบและทำหมันแล้ว นิสัยขี้อ้อน เข้ากับเด็กได้ดี ไม่ดุ',
          'กรุงเทพมหานคร', now() - interval '3 days')
  RETURNING id INTO khaopun;

  INSERT INTO pets (owner_id, name, species, breed, age_months, sex, size,
                    vaccinated, neutered, weight_kg, description, location, created_at)
  VALUES (somchai, 'มะม่วง', 'dog', 'ลาบราดอร์ผสม', 36, 'female', 'large',
          true, true, 24.00,
          'มะม่วงเป็นน้องที่สงบมาก ชอบนอนมากกว่าวิ่ง เหมาะกับบ้านที่อยากได้เพื่อนเงียบ ๆ',
          'กรุงเทพมหานคร', now() - interval '10 days')
  RETURNING id INTO mameung;

  -- ---------- ประกาศของมาลี ----------
  INSERT INTO pets (owner_id, name, species, breed, age_months, sex, size,
                    vaccinated, neutered, weight_kg, description, location, created_at)
  VALUES (malee, 'ส้มโอ', 'cat', 'ส้มไทย', 6, 'female', 'small',
          true, false, 3.20,
          'ส้มโอเพิ่งหย่านม ซนมากแต่ใช้กระบะทรายเป็นแล้ว กำลังหาบ้านที่มีเวลาเล่นด้วย',
          'เชียงใหม่', now() - interval '1 day')
  RETURNING id INTO somo;

  INSERT INTO pets (owner_id, name, species, breed, age_months, sex, size,
                    vaccinated, neutered, weight_kg, description, location, created_at)
  VALUES (malee, 'ทอฟฟี่', 'cat', 'สก็อตติชโฟลด์ผสม', 24, 'male', 'small',
          true, true, 4.80,
          'ทอฟฟี่เป็นแมวที่ติดคนมาก ชอบนอนตัก ไม่ข่วนเฟอร์นิเจอร์',
          'เชียงใหม่', now() - interval '6 days')
  RETURNING id INTO toffee;

  -- ประกาศที่ได้บ้านแล้ว — ต้องหลุดจาก deck แต่ยังอยู่บนโปรไฟล์
  INSERT INTO pets (owner_id, name, species, breed, age_months, sex, size,
                    vaccinated, neutered, description, location,
                    status, adopted_at, created_at)
  VALUES (malee, 'ลาเต้', 'cat', 'ขาวมณี', 12, 'female', 'small',
          true, true, 'ลาเต้ได้บ้านใหม่ที่เชียงรายแล้ว ขอบคุณทุกคนที่ช่วยแชร์',
          'เชียงใหม่', 'adopted', now() - interval '2 days', now() - interval '30 days')
  RETURNING id INTO latte;

  -- ---------- รูปภาพ (media_type ปล่อยเป็นค่า default 'photo' — ยังไม่เปิดวิดีโอ) ----------
  INSERT INTO pet_media (pet_id, storage_key, url, width, height, sort_order) VALUES
    (khaopun, 'pets/seed/khaopun-1.jpg', 'https://picsum.photos/seed/khaopun1/800/1000', 800, 1000, 0),
    (khaopun, 'pets/seed/khaopun-2.jpg', 'https://picsum.photos/seed/khaopun2/800/1000', 800, 1000, 1),
    (mameung, 'pets/seed/mameung-1.jpg', 'https://picsum.photos/seed/mameung1/800/1000', 800, 1000, 0),
    (somo,    'pets/seed/somo-1.jpg',    'https://picsum.photos/seed/somo1/800/1000',    800, 1000, 0),
    (somo,    'pets/seed/somo-2.jpg',    'https://picsum.photos/seed/somo2/800/1000',    800, 1000, 1),
    (toffee,  'pets/seed/toffee-1.jpg',  'https://picsum.photos/seed/toffee1/800/1000',  800, 1000, 0),
    (latte,   'pets/seed/latte-1.jpg',   'https://picsum.photos/seed/latte1/800/1000',   800, 1000, 0);

  -- ---------- แท็กนิสัย ----------
  -- ใช้ slug คงที่จาก migration 007 แทนการพิมพ์ label ซ้ำ กันสะกดผิดแล้วจับคู่ไม่เจอ
  INSERT INTO pet_traits (pet_id, trait_id)
  SELECT khaopun, id FROM traits WHERE slug IN ('affectionate', 'kid_friendly', 'energetic');
  INSERT INTO pet_traits (pet_id, trait_id)
  SELECT mameung, id FROM traits WHERE slug IN ('quiet', 'independent');
  INSERT INTO pet_traits (pet_id, trait_id)
  SELECT somo, id FROM traits WHERE slug IN ('energetic', 'social');
  INSERT INTO pet_traits (pet_id, trait_id)
  SELECT toffee, id FROM traits WHERE slug IN ('affectionate', 'chill');

  -- ---------- การปัด ----------
  -- ณัฐพงศ์ถูกใจข้าวปั้นและส้มโอ / ไม่สนใจมะม่วง
  INSERT INTO likes  (user_id, pet_id) VALUES (nattapong, khaopun), (nattapong, somo);
  INSERT INTO passes (user_id, pet_id) VALUES (nattapong, mameung);

  -- พลอยถูกใจทอฟฟี่
  INSERT INTO likes (user_id, pet_id) VALUES (ploy, toffee);

  -- ---------- แชท ----------
  -- ต้องสร้างห้องพร้อมข้อความแรกใน transaction เดียวกันเสมอ
  -- ไม่งั้น constraint trigger จะปฏิเสธตอน COMMIT
  INSERT INTO conversations (pet_id, initiator_id, owner_id)
  VALUES (khaopun, nattapong, somchai)
  RETURNING id INTO conv;

  INSERT INTO messages (conversation_id, sender_id, body, created_at) VALUES
    (conv, nattapong, 'สวัสดีครับ สนใจน้องข้าวปั้นครับ ยังหาบ้านอยู่ไหมครับ',
     now() - interval '2 hours'),
    (conv, somchai,   'ยังอยู่ครับ น้องนิสัยดีมาก ไม่ทราบว่าที่บ้านมีสัตว์เลี้ยงตัวอื่นไหมครับ',
     now() - interval '1 hour 40 minutes'),
    (conv, nattapong, 'ไม่มีครับ อยู่บ้านเดี่ยว มีสวนเล็ก ๆ ด้วยครับ',
     now() - interval '1 hour 20 minutes');

  INSERT INTO conversations (pet_id, initiator_id, owner_id)
  VALUES (toffee, ploy, malee)
  RETURNING id INTO conv;

  INSERT INTO messages (conversation_id, sender_id, body, created_at) VALUES
    (conv, ploy, 'สนใจน้องทอฟฟี่ค่ะ อยู่คอนโดเลี้ยงได้ไหมคะ', now() - interval '30 minutes');

  RAISE NOTICE 'seed เรียบร้อย — ผู้ใช้ 4 คน, ประกาศ 5 รายการ, รูป 7 ใบ, แท็ก 9 รายการ, ห้องแชท 2 ห้อง';
  RAISE NOTICE 'หมายเหตุ: password_hash เป็นค่าสมมติ ล็อกอินผ่าน API ด้วยบัญชีเหล่านี้ไม่ได้';
END
$seed$;

COMMIT;

-- ---------- สรุปผล ----------
SELECT 'users' AS ตาราง, count(*) AS จำนวน FROM users WHERE email LIKE '%@petpaws.dev'
UNION ALL SELECT 'pets',          count(*) FROM pets  p JOIN users u ON u.id=p.owner_id WHERE u.email LIKE '%@petpaws.dev'
UNION ALL SELECT 'pet_media',     count(*) FROM pet_media
UNION ALL SELECT 'pet_traits',    count(*) FROM pet_traits
UNION ALL SELECT 'likes',         count(*) FROM likes
UNION ALL SELECT 'passes',        count(*) FROM passes
UNION ALL SELECT 'conversations', count(*) FROM conversations
UNION ALL SELECT 'messages',      count(*) FROM messages;
