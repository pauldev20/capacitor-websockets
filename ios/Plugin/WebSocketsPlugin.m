#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(WebSocketsPlugin, "WebSockets",
           CAP_PLUGIN_METHOD(startServer, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(startClient, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(stop, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(sendMessage, CAPPluginReturnPromise);
)
