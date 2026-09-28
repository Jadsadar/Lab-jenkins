import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  // CI ต้องไม่มี test.only หลงเหลือ และไม่ retry จนบังเทสต์ที่พังจริง
  forbidOnly: true,
  retries: 0,
  reporter: [
    ['list'],
    ['html', { outputFolder: 'playwright-report', open: 'never' }],
    ['junit', { outputFile: 'results/e2e-junit.xml' }],
  ],
  use: {
    // Jenkins ส่ง API_BASE_URL=http://api:3000 (ชื่อ service ใน docker-compose.e2e.yml)
    baseURL: process.env.API_BASE_URL ?? 'http://localhost:3000',
  },
});
