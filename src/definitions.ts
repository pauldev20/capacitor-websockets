import type { PluginListenerHandle } from "@capacitor/core";

export interface SocketIdentity {
  uuid: string;
}
export interface SocketData extends SocketIdentity {
  ip?: string;
  host?: number;
}

export interface CloseData {
  connection?: SocketData;
  error: string;
}
export interface MessageData {
  connection?: SocketData;
  message: string;
}

export interface StartOptions {
  port: number;
}
export interface ClientOptions {
  url: string;
}

export interface WebSocketsPlugin {
  startServer(options?: StartOptions): Promise<{ port: number }>;
  startClient(options?: ClientOptions): Promise<{ url: string }>;
  stop(): Promise<void>;
  sendMessage(options?: MessageData): Promise<void>;

  addListener(
    eventName: 'onOpen',
    listenerFunc: (connection: SocketData) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle;
  addListener(
    eventName: 'onClose',
    listenerFunc: (data: CloseData) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle;
  addListener(
    eventName: 'onMessage',
    listenerFunc: (data: MessageData) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle;
  addListener(
    eventName: 'onError',
    listenerFunc: (data: CloseData) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle;
}
