import { Body, Controller, Delete, HttpCode, HttpStatus, Param, Post } from '@nestjs/common';
import { ModerationService } from './moderation.service.js';
import { CreateReportDto } from './dto/create-report.dto.js';
import { CreateBlockDto } from './dto/create-block.dto.js';
import { CurrentUser, type AuthUser } from '../common/current-user.decorator.js';

@Controller()
export class ModerationController {
  constructor(private readonly moderationService: ModerationService) {}

  @Post('reports')
  createReport(@CurrentUser() user: AuthUser, @Body() dto: CreateReportDto) {
    return this.moderationService.createReport(user.id, dto);
  }

  @HttpCode(HttpStatus.OK)
  @Post('blocks')
  createBlock(@CurrentUser() user: AuthUser, @Body() dto: CreateBlockDto) {
    return this.moderationService.createBlock(user.id, dto);
  }

  @Delete('blocks/:userId')
  deleteBlock(@CurrentUser() user: AuthUser, @Param('userId') blockedUserId: string) {
    return this.moderationService.deleteBlock(user.id, blockedUserId);
  }
}
