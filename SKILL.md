---
name: petpaws
description: คู่มือการพัฒนาแอป Petpaws — แอปปัดหาสัตว์เลี้ยง (pet adoption swipe app) ที่มีโปรไฟล์เจ้าของ, โพสประกาศหาบ้าน, ระบบปัดถูกใจ และแชท DM ระหว่างผู้ใช้กับเจ้าของสัตว์ ใช้สกิลนี้ทุกครั้งที่ผู้ใช้พูดถึง Petpaws, แอปปัดหาสัตว์เลี้ยง, หน้าปัด/swipe deck, การ์ดสัตว์เลี้ยง, โพสประกาศหาบ้าน, รายการที่ถูกใจ, แชทเจ้าของสัตว์ หรือขอให้แก้/เพิ่มฟีเจอร์ในโค้ดเบสนี้ — รวมถึงตอนที่ถามแค่ว่า "ทำหน้าโปรไฟล์ยังไง" หรือ "รีแฟคเตอร์โค้ดหน่อย" โดยไม่ได้เอ่ยชื่อแอปตรง ๆ
---

# Petpaws

แอปปัดหาสัตว์เลี้ยงแบบ Tinder สำหรับหาบ้านให้สัตว์ ผู้ใช้ปัดดูการ์ดสัตว์เลี้ยง ปัดขวาเพื่อถูกใจ แล้วทักแชท DM ไปหาเจ้าของได้โดยตรง ผู้ใช้ทุกคนลงประกาศสัตว์ของตัวเองได้ และก็ปัดดูสัตว์ของคนอื่นได้ด้วย — ไม่มีการแบ่งบทบาทเป็น "ผู้ลงประกาศ" กับ "ผู้รับเลี้ยง" แยกกัน ทุกคนคือ user คนเดียวกันที่ทำได้ทั้งสองอย่าง

## Domain model

กฎเหล่านี้เป็นแกนของทั้งระบบ ถ้าเขียนโค้ดขัดกับข้อไหน แปลว่าออกแบบผิดตั้งแต่ต้น:

- `User` 1 คน มี `Pet` ได้หลายตัว
- `Pet` 1 ตัว มีเจ้าของได้คนเดียว (`pet.owner_id` เป็น field เดียว ไม่ใช่ตาราง join) — ห้ามทำ co-owner หรือ many-to-many
- `Pet` ทุกตัวผูกกับโปรไฟล์เจ้าของเสมอ กดจากการ์ดสัตว์ไปโปรไฟล์เจ้าของได้ และกดจากโปรไฟล์ไปดูสัตว์แต่ละตัวได้
- `Like` = (user ที่ปัด, pet ที่ถูกปัด) ผูกกับ **pet** ไม่ใช่ owner เพราะคนอาจถูกใจแมวตัวหนึ่งของเจ้าของแต่ไม่สนใจตัวอื่น
- `Conversation` เกิดระหว่าง user 2 คน และอ้างอิง pet ที่เป็นต้นเรื่อง (`pet_id`) เพื่อให้เจ้าของรู้ว่าทักมาเรื่องสัตว์ตัวไหน
- ห้ามปัดสัตว์ของตัวเอง — กรองออกตั้งแต่ชั้น query ไม่ใช่ซ่อนที่ฝั่ง UI

ตัวอย่าง entity หลัก:

```
User(id, email, password_hash, display_name, avatar_url, bio, created_at)
Pet(id, owner_id → User.id, name, species, breed, age_months, sex,
    size, vaccinated, neutered, description, location, status, created_at)
PetPhoto(id, pet_id → Pet.id, url, sort_order)
Like(id, user_id, pet_id, created_at)          -- unique(user_id, pet_id)
Pass(id, user_id, pet_id, created_at)          -- ปัดซ้าย เก็บไว้กันเด้งซ้ำ
Conversation(id, pet_id, initiator_id, owner_id, last_message_at)
Message(id, conversation_id, sender_id, body, created_at, read_at)
```

`Pet.status` มีค่า `available | pending | adopted` — สัตว์ที่ `adopted` ต้องหลุดจาก deck อัตโนมัติ แต่ยังอยู่บนโปรไฟล์เจ้าของพร้อมป้ายสถานะ

## หน้าจอทั้งหมด

มีแค่ 6 กลุ่มนี้ ถ้ากำลังจะเพิ่มหน้าที่ 7 ให้ถามผู้ใช้ก่อนว่าจำเป็นจริงไหม:

1. **Auth** — สมัคร / เข้าสู่ระบบ / ลืมรหัสผ่าน
2. **Swipe deck** — หน้าหลัก ปัดการ์ดสัตว์ กดการ์ดเพื่อเปิดรายละเอียด
3. **Pet detail** — รูปสัตว์ทั้งหมด + ข้อมูลสัตว์ + ลิงก์ไปโปรไฟล์เจ้าของ + ปุ่มทักแชท
4. **Profile** — โปรไฟล์เจ้าของ พร้อมโพสสัตว์ของเขาแบบ grid กดเข้าไปดูรายละเอียดได้ ถ้าเป็นโปรไฟล์ตัวเองจะมีปุ่มลงประกาศ/แก้ไข/ลบ
5. **Likes** — ประวัติสัตว์ที่เราเคยกดถูกใจ
6. **Chat** — รายการห้องแชท และหน้าห้องแชทรายตัว

### ไม่มี Reels

โปรเจกต์นี้ **ไม่มีฟีเจอร์ reels / วิดีโอฟีด** ถ้าเจอโค้ด route, component, asset, API หรือ dependency ที่เกี่ยวกับ reels ให้ลบทิ้งทั้งหมดรวมถึงเมนู tab bar ที่ชี้ไปหามัน — ไม่ต้องคอมเมนต์ทิ้งไว้ ไม่ต้องซ่อนด้วย feature flag แล้วรายงานผู้ใช้ว่าลบอะไรไปบ้าง

### Chat กับ Likes ต้องแยกกันเด็ดขาด

สองอย่างนี้คนละเรื่องกันและมักถูกเขียนปนกันจนพัง:

- **Likes** = สิ่งที่เราสนใจฝ่ายเดียว เจ้าของไม่รู้ตัว ไม่มี unread badge
- **Chat** = บทสนทนาจริงที่เกิดขึ้นแล้ว มี unread count มี realtime

แยกกันทั้ง route, ไฟล์ฟีเจอร์, state store และ API endpoint ห้ามใช้ store ก้อนเดียวกัน ห้ามทำหน้ารวมที่มี tab สลับระหว่างสองอัน และการกดถูกใจต้อง **ไม่** สร้างห้องแชทอัตโนมัติ — ห้องแชทเกิดตอนผู้ใช้กดส่งข้อความแรกเท่านั้น

## Frontend

### โครงไฟล์: 1 ฟีเจอร์ = 1 โฟลเดอร์

จัดโค้ดแบบ feature-based ไม่ใช่ type-based (ห้ามมีโฟลเดอร์รวม `components/` ยักษ์ที่ยัดทุกอย่าง) ทุกฟีเจอร์ต้องอ่านจบได้ในโฟลเดอร์เดียว:

```
src/
├── features/
│   ├── auth/          (หน้า login, register, ฟอร์ม, hook, api)
│   ├── swipe/         (deck, การ์ด, gesture, hook)
│   ├── pet-detail/
│   ├── profile/       (โปรไฟล์ + โพสสัตว์ + ฟอร์มลงประกาศ)
│   ├── likes/
│   └── chat/          (รายการห้อง + ห้องแชท)
├── shared/            (ui primitives, api client, hooks, utils ที่ใช้ ≥2 ฟีเจอร์)
└── app/               (routing, providers, layout, tab bar)
```

ในแต่ละ feature ใช้โครงเดียวกัน: `index.ts` (export เฉพาะสิ่งที่ข้างนอกใช้), `api.ts`, `components/`, `hooks/`, `types.ts`

**กฎการอ้างอิง:** feature นำเข้าจาก `shared/` ได้ แต่ห้าม import ข้าม feature ตรง ๆ (`features/chat` ห้าม import `features/likes/...`) ถ้ามีอะไรต้องใช้ร่วมกันจริง ให้ย้ายขึ้นไป `shared/` การอนุญาตให้ import ข้ามกันคือจุดเริ่มของ spaghetti ทุกครั้ง

### เช็ค spaghetti ก่อนส่งงาน

ก่อนบอกว่างานเสร็จ ไล่ดูสัญญาณเหล่านี้และแก้ให้เรียบร้อย:

- ไฟล์เกิน ~250 บรรทัด หรือ component ที่ทำเกิน 1 หน้าที่ → แตกไฟล์
- logic ซ้ำใน ≥2 ที่ (เช่น format อายุสัตว์, เรียก API เดิม) → ยกขึ้น `shared/`
- fetch API ตรงใน component → ต้องผ่าน `api.ts` ของฟีเจอร์เสมอ
- state ที่ควรเป็น local แต่ถูกยัดใน global store → ดึงกลับลงมา
- โค้ดที่ตายแล้ว (reels, ฟีเจอร์ที่ถูกลบ, import ที่ไม่มีใครใช้) → ลบ
- ชื่อแปลก ๆ อย่าง `data2`, `handleThing`, `temp` → ตั้งชื่อตามสิ่งที่มันทำจริง
- ตัวเลขหรือสตริงลอย ๆ ที่มีความหมาย → ทำเป็น constant

เวลาแก้โค้ดเดิม ให้แก้ให้อยู่ในโครงข้างบน ไม่ใช่เขียนของใหม่ทับไว้ข้าง ๆ ของเก่า

### UX ที่ห้ามพลาด

- ปัดต้องตอบสนองทันที (optimistic) แล้วค่อยยิง API เบื้องหลัง ถ้า API พัง ค่อยคืนการ์ดกลับพร้อมแจ้งเตือน
- prefetch การ์ดถัดไป 3–5 ใบ และ preload รูปแรกของแต่ละใบ อย่าให้ผู้ใช้เห็นการ์ดเปล่า
- ทุกหน้ามี 3 สถานะเสมอ: loading (skeleton), empty (ข้อความชวนทำอะไรต่อ), error (ปุ่มลองใหม่)

## Backend

### ความเร็วมาก่อน

เป้าหมาย: หน้า deck ตอบใน < 100ms, ส่งข้อความ < 150ms ทำตามนี้ตั้งแต่แรก อย่ารอ optimize ทีหลัง

- **Index ให้ครบ** ตั้งแต่วันแรก: `pet(status, created_at)`, `pet(owner_id)`, `like(user_id, created_at)`, `like(user_id, pet_id) unique`, `message(conversation_id, created_at desc)`, `conversation(owner_id, last_message_at desc)`, `conversation(initiator_id, last_message_at desc)`
- **กัน N+1 query** — โหลดสัตว์พร้อมรูปและข้อมูลเจ้าของในรอบเดียว (join หรือ batch load) ห้าม loop query ทีละตัว
- **Deck ใช้ keyset pagination** ไม่ใช่ `OFFSET` และส่งกลับทีละ 10–20 ใบ ไม่ใช่ทั้งหมด
- **query deck ต้องกรองในฐานข้อมูล**: ตัดสัตว์ของตัวเอง, ตัดตัวที่เคย like/pass แล้ว, ตัดตัวที่ `adopted` — อย่าดึงมาทั้งหมดแล้วกรองใน memory
- **Cache** deck ที่คำนวณแล้วของแต่ละ user ไว้ใน Redis สั้น ๆ (30–60 วินาที) และ invalidate เมื่อมีการปัดหรือมีประกาศใหม่
- ส่งเฉพาะ field ที่หน้าจอใช้จริง การ์ดในเด็คไม่ต้องได้ description เต็ม ๆ กับรูปทั้ง 10 ใบ
- รูปเก็บบน object storage + CDN เสิร์ฟ ขนาดย่อสำหรับการ์ด และขนาดเต็มเฉพาะหน้า detail — ห้ามให้ API เสิร์ฟไฟล์รูปเอง
- แชทใช้ WebSocket สำหรับข้อความเรียลไทม์ และ REST สำหรับดึงประวัติย้อนหลังแบบ paginate

### Login & Authentication

- เก็บรหัสผ่านด้วย bcrypt หรือ argon2 เท่านั้น ห้าม MD5/SHA ล้วน ห้าม log รหัสผ่านหรือ token
- ใช้ JWT access token อายุสั้น (15 นาที) คู่กับ refresh token อายุยาว (30 วัน) ที่หมุนเวียนทุกครั้งที่ใช้และเพิกถอนได้
- ทุก endpoint ยกเว้น register/login/refresh ต้องผ่าน middleware ตรวจ auth เป็นค่าเริ่มต้น — ถ้าลืมใส่ก็ต้องปิดไว้ก่อน ไม่ใช่เปิดไว้ก่อน
- **ตรวจสิทธิ์ความเป็นเจ้าของทุกครั้ง**: แก้/ลบสัตว์ได้เฉพาะ `pet.owner_id == current_user.id` และอ่านห้องแชทได้เฉพาะคู่สนทนาสองคนนั้น อย่าไว้ใจ id ที่ client ส่งมา
- rate limit: login 5 ครั้ง/นาที/IP, ส่งข้อความ 30 ครั้ง/นาที/user, ปัด 100 ครั้ง/นาที/user
- validate input ทุกตัวที่ขอบ API และคืน error เป็นรูปแบบเดียวกันทั้งระบบ

### API endpoints หลัก

```
POST   /auth/register            POST /auth/login       POST /auth/refresh    POST /auth/logout
GET    /deck?cursor=             ดึงการ์ดชุดถัดไป
POST   /pets/:id/like            POST /pets/:id/pass
GET    /likes                    ประวัติที่เราถูกใจ (paginate)
GET    /pets/:id                 รายละเอียดสัตว์ + เจ้าของ
POST   /pets                     PATCH /pets/:id        DELETE /pets/:id
GET    /users/:id                โปรไฟล์ + โพสสัตว์ของเขา
GET    /conversations            รายการห้อง + unread count
GET    /conversations/:id/messages?cursor=
POST   /conversations            สร้างห้อง (ต้องมีข้อความแรกเสมอ) + pet_id
POST   /conversations/:id/messages
```

## Checklist ก่อนส่งงาน

- [ ] ฟีเจอร์ใหม่อยู่ในโฟลเดอร์ `features/` ของตัวเอง ไม่มี import ข้ามฟีเจอร์
- [ ] Chat กับ Likes ยังแยกกันสนิททั้ง route, store และ API
- [ ] ไม่มีร่องรอย reels หลงเหลือ
- [ ] ไม่มีสัตว์ของตัวเองโผล่ใน deck และไม่มีตัวที่ปัดไปแล้วเด้งซ้ำ
- [ ] query ใหม่ทุกอันมี index รองรับ และไม่มี N+1
- [ ] endpoint ใหม่มี auth + ตรวจสิทธิ์เจ้าของ
- [ ] ไล่รายการ spaghetti ด้านบนแล้ว
