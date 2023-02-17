//
//  WebSocketsServerConnection.swift
//  Plugin
//
//  Created by Paul Geeser on 16.02.23.
//

import Foundation
import Network

class WebSocketsServerConnection {
    // MARK: public properties
    let id: String
    var onReadyHandler: (() -> ())? = nil
    var onStopHandler: ((Error?) -> Void)? = nil
    var onErrorHandler: ((Error) -> Void)? = nil
    var onReceiveStringHandler: ((String) -> ())? = nil
    var onReceiveDataHandler: ((Data) -> ())? = nil
    
    // MARK: computed properties
    var host: String {
        get {
            return String(self.connection.currentPath?.localEndpoint!.debugDescription.split(separator: ":")[0] ?? "")
        }
    }
    var port: UInt16 {
        get {
            return UInt16(self.connection.currentPath?.localEndpoint!.debugDescription.split(separator: ":")[1] ?? "") ?? 0
        }
    }

    // MARK: private properties
    private let queue: DispatchQueue
    private let connection: NWConnection

    // MARK: public methods
    init(newConnection: NWConnection, queue: DispatchQueue) {
        self.queue = queue
        self.id = UUID().uuidString
        self.connection = newConnection
    }
    
    func start() {
        #if DEBUG
            print("WebSockets: ServerConnection \(self.id) starting...")
        #endif

        self.connection.stateUpdateHandler = self.stateDidChange(to:)
        self.setupReceiver()
        self.connection.start(queue: self.queue)
    }
    
    func stop() {
        #if DEBUG
            print("WebSockets: ServerConnection \(self.id) is stopping...")
        #endif
        
        self.connection.cancel()
    }
    
    func send(string: String) {
        let metaData = NWProtocolWebSocket.Metadata(opcode: .text)
        let context = NWConnection.ContentContext(identifier: "textContext", metadata: [metaData])
        self.sendData(data: string.data(using: .utf8) ?? Data(), context: context)
    }

    func send(data: Data) {
        let metaData = NWProtocolWebSocket.Metadata(opcode: .binary)
        let context = NWConnection.ContentContext(identifier: "binaryContext", metadata: [metaData])
        self.sendData(data: data, context: context)
    }

    // MARK: private methods
    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .ready:
            #if DEBUG
                print("WebSockets: ServerConnection \(self.id) is ready")
            #endif
            self.onReadyHandler?()
            break
        case .waiting(let error):
            self.errorReceived(error: error)
        case .cancelled:
            self.stopConnection(error: nil)
        case .failed(let error):
            self.stopConnection(error: error)
        default:
            break
        }
    }

    private func setupReceiver() {
        self.connection.receiveMessage() { (data, context, isComplete, error) in
            if let context = context, context.isFinal {
                self.connection.cancel()
                return
            } else if let data = data, let context = context, !data.isEmpty {
                self.receiveData(data: data, context: context)
            }
            if let error = error {
                self.errorReceived(error: error)
            } else {
                self.setupReceiver()
            }
        }
    }
    
    private func receiveData(data: Data, context: NWConnection.ContentContext) {
        guard let metadata = context.protocolMetadata.first as? NWProtocolWebSocket.Metadata else {
            return
        }

        #if DEBUG
            print("WebSockets: ServerConnection \(self.id) received data - \(String(describing: data))")
        #endif
        
        switch metadata.opcode {
        case .binary:
            self.onReceiveDataHandler?(data)
        case .text:
            guard let string = String(data: data, encoding: .utf8) else {
                return
            }
            self.onReceiveStringHandler?(string)
        case .ping:
//            pong()
            break
        case .close:
            break
        default:
            break
        }
    }
    
    private func sendData(data: Data, context: NWConnection.ContentContext) {
        self.connection.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed( { error in
            #if DEBUG
                print("WebSockets: ServerConnection \(self.id) sent data - \(String(describing: data))")
            #endif
            
            if let error = error {
                self.errorReceived(error: error)
                return
            }
        }))
    }
    
    private func errorReceived(error: NWError) {
        #if DEBUG
            print("WebSockets: ServerConnection received error - \(error.debugDescription)")
        #endif
        
        self.onErrorHandler?(error)
    }
    
    private func stopConnection(error: Error?) {
        if (error != nil) {
            self.connection.stateUpdateHandler = nil
        }
        if let onStopHandler = self.onStopHandler {
            self.onStopHandler = nil
            onStopHandler(error)
        }
        if let error = error {
            print("WebSockets: ServerConnection \(id) did fail with error - \(error.localizedDescription)")
        } else {
            #if DEBUG
                print("WebSockets: ServerConnection \(self.id) did stop...")
            #endif
        }
    }
}
