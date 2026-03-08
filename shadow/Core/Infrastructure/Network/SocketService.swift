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
final class SocketService: SocketServiceProtocol {
    private let logPrefix = "[SocketService]"

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
        print(
            "\(logPrefix) connect() called with url=\(url). isConnected=\(isConnected)"
        )
        guard !isConnected else { return }

        let socketURL = URL(string: url)!
        manager = SocketManager(
            socketURL: socketURL,
            config: [
                .log(false),
                .compress,
                .reconnects(true),
                .reconnectWait(2),
                .reconnectAttempts(3),
            ]
        )
        print("\(logPrefix) SocketManager created with URL=\(socketURL)")

        socket = manager?.defaultSocket

        setupBaseEvents()
        socket?.connect()
    }

    func disconnect() {
        print("\(logPrefix) disconnect() called. wasConnected=\(isConnected)")
        socket?.disconnect()
        isConnected = false
        mySocketId = nil
    }

    // MARK: - Base events (conexion/desconexion)

    private func setupBaseEvents() {
        print("\(logPrefix) setupBaseEvents() registering handlers")
        socket?.on(clientEvent: .connect) { [weak self] _, _ in
            print(
                "\(self?.logPrefix ?? "[SocketService]") socket connected. sid=\(self?.socket?.sid ?? "nil")"
            )
            self?.isConnected = true
            self?.mySocketId = self?.socket?.sid
            print("✅ iOS conectado al servidor: \(self?.mySocketId ?? "")")
        }

        socket?.on(clientEvent: .disconnect) { [weak self] _, _ in
            print(
                "\(self?.logPrefix ?? "[SocketService]") socket disconnected event received"
            )
            self?.isConnected = false
            self?.mySocketId = nil
            print("🔌 iOS desconectado del servidor")
        }

        socket?.on(clientEvent: .error) { [weak self] data, _ in
            print(
                "\(self?.logPrefix ?? "[SocketService]") clientEvent .error received. data=\(data)"
            )
            if let error = data.first {
                print("❌ Socket error:", error)
            }
        }

        // Registra todos los eventos del servidor
        // para despacharlos a los handlers registrados
        for event in [
            SocketOnEvent.roomCreated, .roomJoined, .roomDestroyed,
            .myRooms,
            .participantJoined, .participantLeft,
            .messageReceive, .messageSent,
            .keyReceive,
            .securityAlert, .deadManConfirmed, .deadManWarning,
            .typingStart, .typingStop,
            .error,
        ] {
            socket?.on(event.rawValue) { [weak self] data, _ in
                print(
                    "\(self?.logPrefix ?? "[SocketService]") on(\(event.rawValue)) received with \(data.count) item(s). first=\(String(describing: data.first))"
                )
                self?.handlers[event.rawValue]?(data)
            }
        }
    }

    // MARK: - Emitir eventos al servidor

    func emit(_ event: SocketEmitEvent, _ data: [String: Any]) {
        print(
            "\(logPrefix) emit(\(event.rawValue)) with data=\(data). isConnected=\(isConnected)"
        )
        guard isConnected else {
            print(
                "\(logPrefix) ⚠️ Not connected — cannot emit \(event.rawValue). Queueing not implemented."
            )
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
        print("\(logPrefix) handler registered for on-event: \(event.rawValue)")
    }

    func off(_ event: SocketOnEvent) {
        handlers.removeValue(forKey: event.rawValue)
        print("\(logPrefix) handler removed for on-event: \(event.rawValue)")
    }

    // MARK: - Helper para decodificar JSON del servidor

    func decode<T: Decodable>(_ type: T.Type, from data: [Any]) -> T? {
        print(
            "\(logPrefix) decode(\(T.self)) called with data count=\(data.count)"
        )
        guard let dict = data.first as? [String: Any],
            let jsonData = try? JSONSerialization.data(withJSONObject: dict)
        else {
            print(
                "\(logPrefix) decode failed: data.first is not [String: Any] or JSON serialization failed. data.first=\(String(describing: data.first))"
            )
            return nil
        }

        do {
            let decoded = try JSONDecoder().decode(type, from: jsonData)
            print("\(logPrefix) decode success for \(T.self)")
            return decoded
        } catch {
            print("\(logPrefix) decode failed for \(T.self): \(error)")
            return nil
        }
    }
}
