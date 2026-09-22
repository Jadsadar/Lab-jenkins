import { Body, Controller, Get, Param, Patch } from '@nestjs/common';
import { UsersService } from './users.service.js';
import { UpdateProfileDto } from './dto/update-profile.dto.js';
import { CurrentUser, type AuthUser } from '../common/current-user.decorator.js';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  // ระวังลำดับ: ต้องมาก่อน @Get(':id') ไม่งั้น Nest จะจับ "me" เป็นค่า :id
  @Get('me')
  getMe(@CurrentUser() user: AuthUser) {
    return this.usersService.getMe(user.id);
  }

  @Patch('me')
  updateMe(@CurrentUser() user: AuthUser, @Body() dto: UpdateProfileDto) {
    return this.usersService.updateMe(user.id, dto);
  }

  @Get(':id')
  getPublic(@Param('id') id: string) {
    return this.usersService.getPublic(id);
  }
}
