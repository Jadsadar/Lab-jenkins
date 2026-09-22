import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Inject, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import type { Server, Socket } from 'socket.io';
import type { Pool } from 'pg';
import { PG_POOL } from '../database/database.module.js';

interface AuthedSocket extends Socket {
  data: { userId?: string };
}

// CORS อ่านจาก process.env ตรง ๆ เพราะ @WebSocketGateway ต้องกำหนด option ตอน
// class ถูก evaluate (ก่อน Nest DI พร้อมใช้งาน) — ตรรกะเดียวกับ CORS_ORIGIN ใน main.ts
const corsOrigin = process.env.CORS_ORIGIN;

/**
 * WS gateway ของแชท — ใช้รับข้อความสดเท่านั้น "ส่ง" ข้อความยังผ่าน REST
 * (POST /chats/:id/messages) เสมอ ตาม ROADMAP: "REST โหลดประวัติ + WS รับข้อความสด"
 * ChatService เป็นคนเรียก emitNewMessage() หลัง insert สำเร็จ
 *
 * ยังไม่มี Redis adapter — รันได้ถูกต้องเฉพาะตอนมี API instance เดียว
 * ถ้าจะสเกลหลาย instance ต้องเพิ่ม @socket.io/redis-adapter ก่อน (ดู ROADMAP Phase 7.7)
 *
 * หมายเหตุสำคัญ: JwtAuthGuard เป็น APP_GUARD ระดับ global ครอบทุก execution
 * context รวม WS ด้วย — ต้อง return true ทันทีสำหรับ context ที่ไม่ใช่ 'http'
 * (แก้ไว้แล้วใน common/jwt-auth.guard.ts) ไม่งั้น @SubscribeMessage ทุกตัวจะถูก
 * ปฏิเสธเงียบ ๆ เพราะ guard พยายามอ่าน HTTP header จาก request ที่ไม่มีอยู่จริง
 */
@WebSocketGateway({
  namespace: '/chat',
  cors: {
    origin: !corsOrigin || corsOrigin === '*' ? true : corsOrigin.split(','),
    credentials: true,
  },
})
export class ChatGateway implements OnGatewayConnection {
  private readonly logger = new Logger('ChatGateway');

  @WebSocketServer()
  server!: Server;

  constructor(
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
    @Inject(PG_POOL) private readonly pool: Pool,
  ) {}

  /**
   * ยืนยันตัวตนด้วย JWT ตอน handshake เท่านั้น (ไม่ใช่ทุก event) — client ส่ง
   * access token เดียวกับที่ใช้ยิง REST มาทาง `auth.token` ตอน connect:
   * `io(url + '/chat', { auth: { token: accessToken } })`
   */
  handleConnection(client: AuthedSocket) {
    const authToken = client.handshake.auth?.token as string | undefined;
    const headerAuth = client.handshake.headers.authorization;
    const token = authToken ?? (headerAuth?.startsWith('Bearer ') ? headerAuth.slice(7) : undefined);

    if (!token) {
      client.disconnect(true);
      return;
    }

    try {
      const payload = this.jwt.verify<{ sub: string }>(token, {
        secret: this.config.getOrThrow<string>('JWT_ACCESS_SECRET'),
      });
      client.data.userId = payload.sub;
    } catch {
      client.disconnect(true);
    }
  }

  /**
   * client ต้อง join ห้องก่อนถึงจะได้รับ event 'message' ของห้องนั้น — ตรวจว่า
   * เป็นคู่สนทนาจริงก่อน join กันคนแปลกหน้าดักฟังห้องที่ไม่ใช่ของตัวเอง
   * (เงียบ ๆ ไม่ throw เพราะเป็น WS event ไม่ใช่ HTTP request — ผิดก็แค่ไม่ join)
   */
  @SubscribeMessage('join')
  async handleJoin(
    @ConnectedSocket() client: AuthedSocket,
    @MessageBody() data: { conversationId?: string },
  ) {
    const userId = client.data.userId;
    const conversationId = data?.conversationId;
    if (!userId || !conversationId) return;

    const res = await this.pool.query<{ initiator_id: string; owner_id: string }>(
      `SELECT initiator_id, owner_id FROM conversations WHERE id = $1`,
      [conversationId],
    );
    if (res.rows.length === 0) return;
    const row = res.rows[0];
    if (row.initiator_id !== userId && row.owner_id !== userId) {
      this.logger.warn(`user ${userId} tried to join conversation ${conversationId} ที่ไม่ใช่ของตัวเอง`);
      return;
    }

    await client.join(`conversation:${conversationId}`);
  }

  @SubscribeMessage('leave')
  handleLeave(@ConnectedSocket() client: AuthedSocket, @MessageBody() data: { conversationId?: string }) {
    if (data?.conversationId) {
      client.leave(`conversation:${data.conversationId}`);
    }
  }

  /** เรียกจาก ChatService หลัง insert ข้อความสำเร็จ — broadcast ให้ทุกคนที่ join ห้องนี้อยู่ */
  emitNewMessage(conversationId: string, message: Record<string, unknown>) {
    this.server.to(`conversation:${conversationId}`).emit('message', message);
  }
}
