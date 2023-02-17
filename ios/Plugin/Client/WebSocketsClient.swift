//
//  WebSocketClient.swift
//  Plugin
//
//  Created by Paul Geeser on 17.02.23.
//

import Foundation
import Network

enum WebSocketsClientErrors: Error {
    case allreadyConnected(String)
    case onlyTCPSupported
    case noValidURLProvided
}

class WebSocketsClient {
    // MARK: public properties
    var onReadyHandler: (() -> ())? = nil
    var onStopHandler: ((Error?) -> Void)? = nil
    var onErrorHandler: ((Error) -> Void)? = nil
    var onReceiveStringHandler: ((String) -> ())? = nil
    var onReceiveDataHandler: ((Data) -> ())? = nil

    // MARK: private properties
    private var connection: NWConnection?
    private var queue: DispatchQueue
    private var intentionalDisconnect: Bool

    init() {
        self.queue = DispatchQueue(label: "com.pauldev.cpacitor.websockets.client")
        self.intentionalDisconnect = false
    }

    func start(url: String) throws {
        #if DEBUG
            print("WebSockets: Connection starting...")
        #endif

        self.intentionalDisconnect = false
        let urlEndpoint = URL(string: url)
        
        if self.connection != nil {
            throw WebSocketsClientErrors.allreadyConnected("Server allready connected...")
        }
        if urlEndpoint == nil {
            throw WebSocketsClientErrors.noValidURLProvided
        }
        if urlEndpoint?.scheme != "ws" {
            throw WebSocketsClientErrors.onlyTCPSupported
        }

        let parameters = NWParameters(tls: nil)
        let options = NWProtocolWebSocket.Options()
        options.autoReplyPing = true
        parameters.defaultProtocolStack.applicationProtocols.insert(options, at: 0)

        self.connection = NWConnection(to: NWEndpoint.url(urlEndpoint!), using: parameters)
        self.connection?.stateUpdateHandler = stateDidChange(to:)
        setupReceiver()
        self.connection?.start(queue: self.queue)
    }

    func stop(closeCode: NWProtocolWebSocket.CloseCode = .protocolCode(.normalClosure)) {
        #if DEBUG
            print("WebSockets: Connection is stopping...")
        #endif

        self.intentionalDisconnect = true
        if closeCode == .protocolCode(.normalClosure) {
            connection?.cancel()
        } else {
            let metadata = NWProtocolWebSocket.Metadata(opcode: .close)
            metadata.closeCode = closeCode
            let context = NWConnection.ContentContext(identifier: "closeContext", metadata: [metadata])
            self.sendData(data: nil, context: context)
        }
    }

    func send(string: String) {
        let metadata = NWProtocolWebSocket.Metadata(opcode: .text)
        let context = NWConnection.ContentContext(identifier: "textContext", metadata: [metadata])
        self.sendData(data: string.data(using: .utf8) ?? Data(), context: context)
    }

    func send(data: Data) {
        let metadata = NWProtocolWebSocket.Metadata(opcode: .binary)
        let context = NWConnection.ContentContext(identifier: "binaryContext", metadata: [metadata])
        self.sendData(data: data, context: context)
    }

    // MARK: private methods
    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .ready:
            #if DEBUG
                print("WebSockets: Connection is ready")
            #endif
            self.onReadyHandler?()
        case .waiting(let error):
            self.errorReceived(error: error)
        case .failed(let error):
            self.stopConnection(error: error)
        case .cancelled:
            self.stopConnection(error: nil)
        default:
            break
        }
    }

    private func setupReceiver() {
        self.connection?.receiveMessage() { (data, context, isComplete, error) in
            if let data = data, let context = context, !data.isEmpty {
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
            print("WebSockets: Connection received data - \(String(describing: data))")
        #endif
        
        switch metadata.opcode {
        case .binary:
            self.onReceiveDataHandler?(data)
        case .text:
            guard let string = String(data: data, encoding: .utf8) else {
                return
            }
            self.onReceiveStringHandler?(string)
        case .close:
            break
        default:
            break
        }
    }
    
    private func sendData(data: Data?, context: NWConnection.ContentContext) {
        connection?.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed({ error in
            #if DEBUG
                print("WebSockets: Connection sent data - \(String(describing: data))")
            #endif
            
            if let error = error {
                self.errorReceived(error: error)
                return
            }
        }))
    }
    
    private func errorReceived(error: NWError) {
        if self.realError(error: error) {
            #if DEBUG
                print("WebSockets: Connection received error - \(error.debugDescription)")
            #endif

            self.onErrorHandler?(error)
        }
    }

    private func stopConnection(error: NWError?) {
        if let onStopHandler = self.onStopHandler {
            self.onStopHandler = nil
            onStopHandler(self.realError(error: error) ? error :  nil)
        }

        self.connection = nil
        if let error = error, self.realError(error: error) {
            print("WebSockets: Connection did fail with error - \(error.localizedDescription)")
        } else {
            #if DEBUG
                print("WebSockets: Connection did stop...")
            #endif
        }
    }
    
    private func realError(error: NWError?) -> Bool {
        if case let .posix(code) = error {
            if code == .ENOTCONN || code == .ECANCELED, self.intentionalDisconnect == true {
                return false
            }
            return true
        }
        return true
    }
}
