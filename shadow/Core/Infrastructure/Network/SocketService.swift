//
//  SocketService.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 6/03/26.
//

import Foundation
import SocketIO

// shadow/Core/Infrastructure/Network/SocketService.swift
// Servicio central de Socket.IO.
// Equivalente a tu SocketService en Flutter con socket_io_client.
//
// @Observable = la UI se actualiza sola cuando cambia
// el estado de conexion. Como ChangeNotifier en Flutter.

@Observable
final class SocketService {

    // MARK: - Estado de conexion
    var isConnected: Bool = false
    var mySocketId: String? = nil

    // MARK: - Socket
    private var manager: SocketManager?
    private var socket: SocketIOClient?

    // MARK: - Callbacks registrados por los ViewModels
    // Equivalente a los StreamControllers en Flutter
    private var handlers: [String: ([Any]) -> Void] = [:]

    // MARK: - Singleton
    static let shared = SocketService()
    private init() {}

    // MARK: - Conexion

    func connect(url: String = "http://localhost:3000") {
        guard !isConnected else { return }

        let socketURL = URL(string: url)!
        manager = SocketManager(socketURL: socketURL, config: [
            .log(false),
            .compress,
            .reconnects(true),
            .reconnectWait(2),
        ])

        socket = manager?.defaultSocket

        setupBaseEvents()
        socket?.connect()
    }

    func disconnect() {
        socket?.disconnect()
        isConnected = false
        mySocketId = nil
    }

    // MARK: - Base events (conexion/desconexion)

    private func setupBaseEvents() {
        socket?.on(clientEvent: .connect) { [weak self] _, _ in
            self?.isConnected = true
            self?.mySocketId = self?.socket?.sid
            print("✅ iOS conectado al servidor: \(self?.mySocketId ?? "")")
        }

        socket?.on(clientEvent: .disconnect) { [weak self] _, _ in
            self?.isConnected = false
            self?.mySocketId = nil
            print("🔌 iOS desconectado del servidor")
        }

        socket?.on(clientEvent: .error) { _, data in
            print("❌ Socket error:", data)
        }

        // Registra todos los eventos del servidor
        // para despacharlos a los handlers registrados
        for event in [
            SocketOnEvent.roomCreated, .roomJoined, .roomDestroyed,
            .participantJoined, .participantLeft,
            .messageReceive, .messageSent,
            .keyReceive,
            .securityAlert, .deadManConfirmed, .deadManWarning,
            .typingStart, .typingStop,
            .error
        ] {
            socket?.on(event.rawValue) { [weak self] data, _ in
                self?.handlers[event.rawValue]?(data)
            }
        }
    }

    // MARK: - Emitir eventos al servidor

    func emit(_ event: SocketEmitEvent, _ data: [String: Any]) {
        guard isConnected else {
            print("⚠️ No conectado — no se puede emitir \(event.rawValue)")
            return
        }
        socket?.emit(event.rawValue, data)
    }

    // MARK: - Escuchar eventos del servidor
    // Equivalente a socket.on('event', callback) en Flutter
    //
    // Uso:
    //   socketService.on(.roomCreated) { data in
    //     let payload = data.decode(RoomCreatedPayload.self)
    //   }

    func on(_ event: SocketOnEvent, handler: @escaping ([Any]) -> Void) {
        handlers[event.rawValue] = handler
    }

    func off(_ event: SocketOnEvent) {
        handlers.removeValue(forKey: event.rawValue)
    }

    // MARK: - Helper para decodificar JSON del servidor

    func decode<T: Decodable>(_ type: T.Type, from data: [Any]) -> T? {
        guard let dict = data.first as? [String: Any],
              let jsonData = try? JSONSerialization.data(withJSONObject: dict)
        else { return nil }

        return try? JSONDecoder().decode(type, from: jsonData)
    }
}
