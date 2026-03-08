//
//  SocketServiceProtocol.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 8/03/26.
//

import Foundation

/// Defines the contract for the WebSocket service.
protocol SocketServiceProtocol {
    var isConnected: Bool { get }
    var mySocketId: String? { get }
    
    func connect(url: String)
    func disconnect()
    
    func emit(_ event: SocketEmitEvent, _ data: [String: Any])
    @discardableResult
    func on(_ event: SocketOnEvent, handler: @escaping ([Any]) -> Void) -> UUID
    func off(_ event: SocketOnEvent, id: UUID)
    
    func decode<T: Decodable>(_ type: T.Type, from data: [Any]) -> T?
}
