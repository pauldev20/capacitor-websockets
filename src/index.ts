import { registerPlugin } from '@capacitor/core';

import type { WebSocketsPlugin } from './definitions';

const WebSockets = registerPlugin<WebSocketsPlugin>('WebSockets', {
  web: () => import('./web').then(m => new m.WebSocketsWeb()),
});

export * from './definitions';
export { WebSockets };
