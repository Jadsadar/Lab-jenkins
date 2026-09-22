import { Module } from '@nestjs/common';
import { TraitsController } from './traits.controller.js';

@Module({ controllers: [TraitsController] })
export class TraitsModule {}
