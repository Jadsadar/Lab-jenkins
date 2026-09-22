import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Reflector } from '@nestjs/core';
import { AppException } from './app-exception.js';
import { IS_PUBLIC_KEY } from './public.decorator.js';

/**
 * Global guard — บังคับ auth เป็นค่าเริ่มต้นทุก route ยกเว้นที่แปะ @Public()
 * ลงทะเบียนใน main.ts เป็น APP_GUARD ระดับ global (ไม่ใช่ต่อ controller)
 * เพื่อไม่ให้มีวันลืมใส่ guard ที่ endpoint ใหม่
 */
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
    private readonly reflector: Reflector,
  ) {}

  canActivate(context: ExecutionContext): boolean {
    // guard นี้เป็น APP_GUARD ระดับ global จึงถูกเรียกกับทุก execution context
    // ไม่ใช่แค่ HTTP รวมถึง @SubscribeMessage ของ ChatGateway ด้วย — WS ยืนยัน
    // ตัวตนของตัวเองแล้วตอน handshake (ดู ChatGateway.handleConnection) ที่นี่จึง
    // ต้องข้าม ไม่งั้น context.switchToHttp().getRequest() จะได้ request ว่าง ๆ
    // แล้ว throw unauthorized ให้ทุก WS event เงียบ ๆ โดยไม่มี error ให้เห็น
    if (context.getType() !== 'http') return true;

    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    const request = context.switchToHttp().getRequest();
    const authHeader: string | undefined = request.headers?.authorization;
    const token = authHeader?.startsWith('Bearer ') ? authHeader.slice(7) : null;

    if (!token) {
      throw AppException.unauthorized('ต้องแนบ Authorization: Bearer <token>');
    }

    try {
      const payload = this.jwt.verify<{ sub: string }>(token, {
        secret: this.config.getOrThrow<string>('JWT_ACCESS_SECRET'),
      });
      request.user = { id: payload.sub };
      return true;
    } catch {
      throw AppException.unauthorized('token หมดอายุหรือไม่ถูกต้อง');
    }
  }
}
