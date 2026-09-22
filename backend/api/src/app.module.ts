import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { APP_GUARD } from '@nestjs/core';
import { AppController } from './app.controller.js';
import { DatabaseModule } from './database/database.module.js';
import { AuthModule } from './auth/auth.module.js';
import { UsersModule } from './users/users.module.js';
import { TraitsModule } from './traits/traits.module.js';
import { PetsModule } from './pets/pets.module.js';
import { MediaModule } from './media/media.module.js';
import { ChatModule } from './chat/chat.module.js';
import { JwtAuthGuard } from './common/jwt-auth.guard.js';
import { validateEnv } from './config/env.validation.js';

@Module({
  imports: [
    // รันจาก backend/api เสมอ (npm run start:dev) — .env จริงอยู่ที่ backend/.env
    // (ไฟล์เดียวกับที่ docker-compose ใช้ ไม่ต้อง duplicate ค่า)
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['../.env', '.env'],
      validate: validateEnv,
    }),
    JwtModule.register({}),
    DatabaseModule,
    AuthModule,
    UsersModule,
    TraitsModule,
    PetsModule,
    MediaModule,
    ChatModule,
  ],
  controllers: [AppController],
  providers: [{ provide: APP_GUARD, useClass: JwtAuthGuard }],
})
export class AppModule {}
