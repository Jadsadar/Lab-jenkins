import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { MediaService } from './media.service.js';
import { AppException } from '../common/app-exception.js';

// เอาแค่ field ที่ media.service.ts ใช้จริง แทนที่จะพึ่ง Express.Multer.File
// ทั้งก้อน — namespace global.Express ของ multer ไม่ merge เข้ากับโปรเจกต์
// โหมด ESM/nodenext นี้ (พังเฉพาะตอน build ไม่ใช่ปัญหาที่ runtime)
interface UploadedFileLike {
  buffer: Buffer;
  mimetype: string;
  size: number;
}

@Controller('media')
export class MediaController {
  constructor(private readonly mediaService: MediaService) {}

  @Post('upload')
  @UseInterceptors(FileInterceptor('file'))
  async upload(@UploadedFile() file?: UploadedFileLike) {
    if (!file) throw new AppException('NO_FILE', 'ไม่พบไฟล์ที่อัปโหลด');
    return this.mediaService.uploadImage(file);
  }
}
