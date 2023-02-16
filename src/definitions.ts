export interface WebSocketsPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
