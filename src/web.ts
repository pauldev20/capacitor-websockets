import { WebPlugin } from '@capacitor/core';

import type { WebSocketsPlugin } from './definitions';

export class WebSocketsWeb extends WebPlugin implements WebSocketsPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
