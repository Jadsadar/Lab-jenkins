import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { ConfigService } from '@nestjs/config';
import { AppModule } from './app.module.js';
import { AllExceptionsFilter } from './common/http-exception.filter.js';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const config = app.get(ConfigService);

  // whitelist: true = field ที่ไม่ได้ประกาศใน DTO ถูกตัดทิ้งก่อนถึง SQL เลย
  // ตาม SKILL.md: "validate input ทุกตัวที่ขอบ API"
  //
  // ตั้งใจไม่ใช้ forbidNonWhitelisted เพราะ edit_dog_screen.dart ส่ง body แบบ
  // `{...widget.dog, "name": ..., ...}` ซึ่งพ่วง field เดิมทั้งก้อนมาด้วย
  // (id, ownerId, status ฯลฯ) — ถ้า forbid จะ reject request ที่ถูกต้องทุกครั้ง
  // whitelist อย่างเดียวก็ปลอดภัยพอแล้ว เพราะ field แปลกปลอมถูกตัดทิ้งเงียบ ๆ
  // ก่อนถึงชั้น service อยู่ดี ไม่มีทางหลุดไปถึง SQL
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
    }),
  );
  app.useGlobalFilters(new AllExceptionsFilter());

  const corsOrigin = config.get<string>('CORS_ORIGIN', '*');
  app.enableCors({
    origin: corsOrigin === '*' ? true : corsOrigin.split(','),
    credentials: true,
  });

  const port = config.get<string>('API_PORT', '3000');
  await app.listen(port);
  // eslint-disable-next-line no-console
  console.log(`PetPaws API listening on http://localhost:${port}`);
}

bootstrap();
