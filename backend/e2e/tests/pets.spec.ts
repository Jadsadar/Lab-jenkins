import { test, expect, type APIRequestContext } from '@playwright/test';

// โจทย์ Lab 05 ใช้แอป to-do (แสดงงาน / สร้างงาน / ทำเครื่องหมายเสร็จ)
// PetPaws เทียบได้เป็น แสดงประกาศ / ลงประกาศ / เปลี่ยนสถานะเป็นถูกรับเลี้ยงแล้ว
// 3 เทสต์ใช้ผู้ใช้และประกาศเดียวกันต่อกัน จึงต้องรันเรียงลำดับ
test.describe.configure({ mode: 'serial' });

const ADOPTED = 'ถูกรับเลี้ยงแล้ว';
const OPEN = 'ยังไม่ถูกรับเลี้ยง';

let api: APIRequestContext;
let petId: string;

test.beforeAll(async ({ playwright, baseURL }) => {
  const suffix = Date.now().toString(36);
  const username = `e2e_${suffix}`;
  const email = `e2e_${suffix}@example.com`;
  // ผ่าน password policy: มีพิมพ์ใหญ่/เล็ก/ตัวเลข/อักขระพิเศษ และไม่มีชื่อผู้ใช้อยู่ข้างใน
  const password = 'Str0ng!Pass';

  const anon = await playwright.request.newContext({ baseURL });
  const register = await anon.post('/auth/register', { data: { username, email, password } });
  expect(register.status(), await register.text()).toBe(201);

  const login = await anon.post('/auth/login', { data: { identifier: username, password } });
  expect(login.status(), await login.text()).toBe(200);
  const { accessToken } = await login.json();
  await anon.dispose();

  api = await playwright.request.newContext({
    baseURL,
    extraHTTPHeaders: { Authorization: `Bearer ${accessToken}` },
  });
});

test.afterAll(async () => {
  await api?.dispose();
});

test('lists my pets', async () => {
  const res = await api.get('/pets/mine');
  expect(res.status()).toBe(200);
  expect(Array.isArray(await res.json())).toBe(true);
});

test('creates a pet listing', async () => {
  const res = await api.post('/pets', {
    data: { name: 'Mochi', province: 'กรุงเทพมหานคร', age: '2 ปี', gender: 'เมีย', weight: '4.5' },
  });
  expect(res.status(), await res.text()).toBe(201);

  const pet = await res.json();
  expect(pet.id).toBeTruthy();
  expect(pet.name).toBe('Mochi');
  expect(pet.status).toBe(OPEN);
  petId = pet.id;

  const mine = await (await api.get('/pets/mine')).json();
  expect(mine.map((p: { id: string }) => p.id)).toContain(petId);
});

test('marks the pet as adopted', async () => {
  const res = await api.patch(`/pets/${petId}`, { data: { status: ADOPTED } });
  expect(res.status(), await res.text()).toBe(200);
  expect((await res.json()).status).toBe(ADOPTED);

  const reloaded = await api.get(`/pets/${petId}`);
  expect((await reloaded.json()).status).toBe(ADOPTED);
});
