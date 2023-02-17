//
//  WebSocketsServer.swift
//  Plugin
//
//  Created by Paul Geeser on 16.02.23.
//

import Foundation
import Network

enum WebSocketsServerErrors: Error {
    case allreadyRunning(String)
    case unableToStart(String)
}

class WebSocketsServer {
    // MARK: private properties
    private var queue: DispatchQueue
    private var listener: NWListener?
    
    // MARK: public properties
    var IDConnection: [String: WebSocketsServerConnection]
    var onConnectionReadyHandler:((WebSocketsServerConnection) -> Void)? = nil
    var onConnectionStopHandler: ((WebSocketsServerConnection, Error?) -> Void)? = nil
    var onConnectionErrorHandler: ((WebSocketsServerConnection, Error) -> Void)? = nil
    var onConnectionReceiveStringHandler: ((WebSocketsServerConnection, String) -> ())? = nil
    var onConnectionReceiveDataHandler: ((WebSocketsServerConnection, Data) -> ())? = nil

    // MARK: public methods
    init() {
        self.queue = DispatchQueue(label: "com.pauldev.cpacitor.websockets.server")
        self.listener = nil
        self.IDConnection = [:]
    }
    
    func start(port: UInt16) throws {
        if (self.listener != nil) {
            throw WebSocketsServerErrors.allreadyRunning("Server allready running: \(String(describing: listener?.port))")
        }
        
        let parameters = NWParameters(tls: nil, tcp: NWProtocolTCP.Options())
        parameters.allowLocalEndpointReuse = true
        parameters.includePeerToPeer = true
        let wsOptions = NWProtocolWebSocket.Options()
        wsOptions.autoReplyPing = true
        parameters.defaultProtocolStack.applicationProtocols.insert(wsOptions, at: 0)
        
        do {
            if let portValue = NWEndpoint.Port(rawValue: UInt16(port)) {
                listener = try! NWListener(using: parameters, on: portValue)
            } else {
                throw WebSocketsServerErrors.unableToStart("Unable to start WebSocket server on port \(port)")
            }
        } catch {
            throw error
        }
        
        listener?.stateUpdateHandler = self.stateDidChange(to:)
        listener?.newConnectionHandler = self.didAccept(newConnection:)
        listener?.start(queue: self.queue)
    }

    func stop() {
        listener?.cancel()
    }

    // MARK: private methods
    private func stateDidChange(to state: NWListener.State) {
        #if DEBUG
            switch state {
            case .ready:
                print("WebSocketServer: Server ready...")
            case .cancelled:
                self.stopServer(error: nil)
            case .failed(let error):
                self.stopServer(error: error)
            default:
                break
            }
        #endif
    }
    
    private func didAccept(newConnection: NWConnection) {
        let connection = WebSocketsServerConnection(newConnection: newConnection, queue: self.queue)
        IDConnection[connection.id] = connection
        connection.start()
        connection.onStopHandler = { err in
            self.connectionStopped(connection: connection)
            self.onConnectionStopHandler?(connection, err)
        }
        connection.onErrorHandler = { err in
            self.onConnectionErrorHandler?(connection, err)
        }
        connection.onReceiveStringHandler = { string in
            self.onConnectionReceiveStringHandler?(connection, string)
        }
        connection.onReceiveDataHandler = { data in
            self.onConnectionReceiveDataHandler?(connection, data)
        }
        connection.onReadyHandler = {
            self.onConnectionReadyHandler?(connection)
        }

        #if DEBUG
            print("WebSockets: Server started ServerConnection \(connection.id)")
        #endif
    }
    
    private func connectionStopped(connection: WebSocketsServerConnection) {
        #if DEBUG
            print("WebSockets: Server closed ServerConnection \(connection.id)")
        #endif

        self.IDConnection.removeValue(forKey: connection.id)
    }
    
    private func stopServer(error: NWError?) {
        self.listener = nil
        for connection in self.IDConnection.values {
            connection.onStopHandler = nil
            connection.stop()
        }
        self.IDConnection.removeAll()
        if let error = error {
            print("WebSockets: Server failed with \(error.debugDescription)")
        } else {
            #if DEBUG
                print("WebSockets: Server stopped")
            #endif
        }
    }
}
