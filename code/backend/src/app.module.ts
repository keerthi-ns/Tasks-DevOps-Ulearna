import { Module } from '@nestjs/common';
import { AppController } from './app.controller';

@Module({
  imports: [],
  controllers: [AppController],  // Registers AppController
  providers: [],
})
export class AppModule {}
