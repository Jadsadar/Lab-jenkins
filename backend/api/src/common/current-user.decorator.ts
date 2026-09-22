import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export interface AuthUser {
  id: string;
}

/** อ่าน user ที่ JwtAuthGuard แนบไว้ใน request — ใช้แทน `req.user.id` ตรง ๆ ทุกที่ */
export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): AuthUser => {
    const request = ctx.switchToHttp().getRequest();
    return request.user as AuthUser;
  },
);
