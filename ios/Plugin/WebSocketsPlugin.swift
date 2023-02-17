import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(WebSocketsPlugin)
public class WebSocketsPlugin: CAPPlugin {
    private let websocketsserver = WebSocketsServer()
    private let websocketsclient = WebSocketsClient()

    @objc func startServer(_ call: CAPPluginCall) {
        guard let portValue = call.getInt("port") else {
            call.reject("A port needs to be provided")
            return
        }

        do {
            try self.websocketsserver.start(port: UInt16(portValue))
        } catch {
            call.reject(error.localizedDescription)
        }

        self.websocketsserver.onConnectionReadyHandler = { conn in
            self.notifyListeners("onOpen", data: [
                "uuid": conn.id,
                "host": conn.host as Any,
                "port": conn.port as Any
            ])
        }
        self.websocketsserver.onConnectionStopHandler = { (conn, error) in
            self.notifyListeners("onClose", data: [
                "uuid": conn.id,
                "error": error.debugDescription
            ])
        }
        self.websocketsserver.onConnectionReceiveDataHandler = { (conn, data) in
            self.notifyListeners("onMessage", data: [
                "message": String(data: data, encoding: .utf8) as Any,
                "connection": [
                    "uuid": conn.id,
                    "host": conn.host as Any,
                    "port": conn.port as Any
                ]
            ])
        }
        self.websocketsserver.onConnectionReceiveStringHandler = { (conn, string) in
            self.notifyListeners("onMessage", data: [
                "message": string,
                "connection": [
                    "uuid": conn.id,
                    "host": conn.host as Any,
                    "port": conn.port as Any
                ]
            ])
        }
        self.websocketsserver.onConnectionErrorHandler = { (conn, error) in
            self.notifyListeners("onError", data: [
                "uuid": conn.id,
                "error": error.localizedDescription
            ])
        }

        call.resolve([
            "port": portValue
        ])
    }
    
    @objc func startClient(_ call: CAPPluginCall) {
        guard let urlValue = call.getString("url") else {
            call.reject("A url needs to be provided")
            return
        }
        
        do {
            try self.websocketsclient.start(url: urlValue)
        } catch {
            call.reject(error.localizedDescription)
        }
        
        self.websocketsclient.onReadyHandler = {
            self.notifyListeners("onOpen", data: [:])
        }
        self.websocketsclient.onStopHandler = { error in
            self.notifyListeners("onClose", data: [
                "error": error.debugDescription
            ])
        }
        self.websocketsclient.onReceiveDataHandler = { data in
            self.notifyListeners("onMessage", data: [
                "message": String(data: data, encoding: .utf8) as Any
            ])
        }
        self.websocketsclient.onReceiveStringHandler = { string in
            self.notifyListeners("onMessage", data: [
                "message": string
            ])
        }
        self.websocketsclient.onErrorHandler = { error in
            self.notifyListeners("onError", data: [
                "error": error.localizedDescription
            ])
        }

        call.resolve([
            "url": urlValue
        ])
    }
    
    @objc func stop(_ call: CAPPluginCall) {
        self.websocketsserver.stop()
        self.websocketsclient.stop()
    }

    @objc func sendMessage(_ call: CAPPluginCall) {
        guard let message = call.getString("message") else {
            call.reject("A message needs to be provided")
            return
        }
        
        if !self.websocketsserver.IDConnection.isEmpty {
            guard let conn = call.getObject("connection") else {
                call.reject("A connection needs to be provided")
                return
            }
            let connection = self.websocketsserver.IDConnection[conn["uuid"] as! String]
            connection?.send(string: message)
        } else {
            self.websocketsclient.send(string: message)
        }
        call.resolve([:])
    }
}
