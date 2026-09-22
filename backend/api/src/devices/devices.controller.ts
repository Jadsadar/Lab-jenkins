import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { DevicesService } from './devices.service.js';
import { RegisterDeviceDto } from './dto/register-device.dto.js';
import { CurrentUser, type AuthUser } from '../common/current-user.decorator.js';

@Controller('devices')
export class DevicesController {
  constructor(private readonly devicesService: DevicesService) {}

  @HttpCode(HttpStatus.OK)
  @Post()
  register(@CurrentUser() user: AuthUser, @Body() dto: RegisterDeviceDto) {
    return this.devicesService.register(user.id, dto);
  }
}
