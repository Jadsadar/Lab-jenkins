import { Global, Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Pool } from 'pg';

export const PG_POOL = Symbol('PG_POOL');

// Global เพื่อให้ทุก module inject PG_POOL ได้โดยไม่ต้อง import DatabaseModule ซ้ำทุกที่
@Global()
@Module({
  providers: [
    {
      provide: PG_POOL,
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const pool = new Pool({
          connectionString: config.getOrThrow<string>('DATABASE_URL'),
          // pool เล็กพอสำหรับ dev/สอบใช้งาน ปรับขึ้นตอนเจอ connection exhausted จริง
          max: 10,
        });
        pool.on('error', (err) => {
          // connection ที่ idle อยู่หลุดกะทันหัน (network blip) ไม่ควรทำให้ process ทั้งตัวตาย
          // eslint-disable-next-line no-console
          console.error('Unexpected PG pool error', err);
        });
        return pool;
      },
    },
  ],
  exports: [PG_POOL],
})
export class DatabaseModule {}
