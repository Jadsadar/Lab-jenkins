import { defineConfig } from 'vitest/config';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  // Resolves the path aliases declared in tsconfig.json, including the ones
  // added by `nest g library`.
  plugins: [tsconfigPaths()],
  test: {
    globals: true,
    root: './',
    include: ['**/*.spec.ts'],
    // junit.xml ให้ Jenkins อ่านผลเทสต์ผ่านคำสั่ง junit (Lab 05 Task 1)
    reporters: ['default', 'junit'],
    outputFile: { junit: './reports/junit.xml' },
    coverage: {
      provider: 'v8',
      // cobertura: ให้ Jenkins (recordCoverage), lcov: ให้ SonarQube
      reporter: ['text', 'cobertura', 'lcov'],
      reportsDirectory: './coverage',
      // วัดเฉพาะโมดูลที่มี unit test แล้ว ส่วนที่เหลือของ API ยังไม่มีเทสต์
      // ถ้าวัดทั้งโปรเจกต์ coverage จะใกล้ 0% และ Quality Gate 70% ไม่มีทางผ่าน
      include: ['src/pets/pet-mappers.ts', 'src/common/home-type.ts'],
    },
  },
});
