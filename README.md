# capacitor-websockets 🔌

Simple WebSockets client and server for the Capacitor framework. It's only a really basic implementation with some caveats.
If you find any bugs or have improvements create an issue or pull request.

## Install

```bash
npm install capacitor-websockets
npx cap sync
```

## API

<docgen-index>

* [`startServer(...)`](#startserver)
* [`startClient(...)`](#startclient)
* [`stop()`](#stop)
* [`sendMessage(...)`](#sendmessage)
* [`addListener('onOpen', ...)`](#addlisteneronopen)
* [`addListener('onClose', ...)`](#addlisteneronclose)
* [`addListener('onMessage', ...)`](#addlisteneronmessage)
* [`addListener('onError', ...)`](#addlisteneronerror)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### startServer(...)

```typescript
startServer(options?: StartOptions | undefined) => Promise<{ port: number; }>
```

| Param         | Type                                                  |
| ------------- | ----------------------------------------------------- |
| **`options`** | <code><a href="#startoptions">StartOptions</a></code> |

**Returns:** <code>Promise&lt;{ port: number; }&gt;</code>

--------------------


### startClient(...)

```typescript
startClient(options?: ClientOptions | undefined) => Promise<{ url: string; }>
```

| Param         | Type                                                    |
| ------------- | ------------------------------------------------------- |
| **`options`** | <code><a href="#clientoptions">ClientOptions</a></code> |

**Returns:** <code>Promise&lt;{ url: string; }&gt;</code>

--------------------


### stop()

```typescript
stop() => Promise<void>
```

--------------------


### sendMessage(...)

```typescript
sendMessage(options?: MessageData | undefined) => Promise<void>
```

| Param         | Type                                                |
| ------------- | --------------------------------------------------- |
| **`options`** | <code><a href="#messagedata">MessageData</a></code> |

--------------------


### addListener('onOpen', ...)

```typescript
addListener(eventName: 'onOpen', listenerFunc: (connection: SocketData) => void) => Promise<PluginListenerHandle> & PluginListenerHandle
```

| Param              | Type                                                                       |
| ------------------ | -------------------------------------------------------------------------- |
| **`eventName`**    | <code>'onOpen'</code>                                                      |
| **`listenerFunc`** | <code>(connection: <a href="#socketdata">SocketData</a>) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt; & <a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

--------------------


### addListener('onClose', ...)

```typescript
addListener(eventName: 'onClose', listenerFunc: (data: CloseData) => void) => Promise<PluginListenerHandle> & PluginListenerHandle
```

| Param              | Type                                                               |
| ------------------ | ------------------------------------------------------------------ |
| **`eventName`**    | <code>'onClose'</code>                                             |
| **`listenerFunc`** | <code>(data: <a href="#closedata">CloseData</a>) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt; & <a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

--------------------


### addListener('onMessage', ...)

```typescript
addListener(eventName: 'onMessage', listenerFunc: (data: MessageData) => void) => Promise<PluginListenerHandle> & PluginListenerHandle
```

| Param              | Type                                                                   |
| ------------------ | ---------------------------------------------------------------------- |
| **`eventName`**    | <code>'onMessage'</code>                                               |
| **`listenerFunc`** | <code>(data: <a href="#messagedata">MessageData</a>) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt; & <a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

--------------------


### addListener('onError', ...)

```typescript
addListener(eventName: 'onError', listenerFunc: (data: CloseData) => void) => Promise<PluginListenerHandle> & PluginListenerHandle
```

| Param              | Type                                                               |
| ------------------ | ------------------------------------------------------------------ |
| **`eventName`**    | <code>'onError'</code>                                             |
| **`listenerFunc`** | <code>(data: <a href="#closedata">CloseData</a>) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt; & <a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

--------------------


### Interfaces


#### StartOptions

| Prop       | Type                |
| ---------- | ------------------- |
| **`port`** | <code>number</code> |


#### ClientOptions

| Prop      | Type                |
| --------- | ------------------- |
| **`url`** | <code>string</code> |


#### MessageData

| Prop             | Type                                              |
| ---------------- | ------------------------------------------------- |
| **`connection`** | <code><a href="#socketdata">SocketData</a></code> |
| **`message`**    | <code>string</code>                               |


#### SocketData

| Prop       | Type                |
| ---------- | ------------------- |
| **`ip`**   | <code>string</code> |
| **`host`** | <code>number</code> |


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |


#### CloseData

| Prop             | Type                                              |
| ---------------- | ------------------------------------------------- |
| **`connection`** | <code><a href="#socketdata">SocketData</a></code> |
| **`error`**      | <code>string</code>                               |

</docgen-api>
