import { IsOptional, IsUUID, MaxLength } from 'class-validator';

export class CreateBlockDto {
  @IsUUID()
  blockedUserId!: string;

  @IsOptional()
  @MaxLength(200)
  reason?: string;
}
