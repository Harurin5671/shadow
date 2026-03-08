//
//  NotificationManager.swift
//  shadow
//

import Foundation
import SwiftUI

/// Orchestrates socket events and translates them into local notifications.
@Observable
final class NotificationManager {
    private let socketService: SocketServiceProtocol
    private let notificationService: LocalNotificationServiceProtocol
    
    // UUIDs for unregistering events
    private var participantJoinedId: UUID?
    private var participantLeftId: UUID?
    private var messageReceiveId: UUID?
    
    init(socketService: SocketServiceProtocol, notificationService: LocalNotificationServiceProtocol) {
        print("[NotificationManager] Initializing...")
        self.socketService = socketService
        self.notificationService = notificationService
        
        // Solicitar permisos al iniciar
        Task {
            do {
                let granted = try await notificationService.requestAuthorization()
                print("[NotificationManager] Notification permission granted: \(granted)")
            } catch {
                print("[NotificationManager] Error requesting notification permission: \(error)")
            }
        }
    }
    
    /// Empieza a escuchar los eventos del Socket para lanzar alertas locales
    func startListening() {
        stopListening()
        print("[NotificationManager] Starting to listen to socket events")
        
        participantJoinedId = socketService.on(.participantJoined) { [weak self] data in
            guard let self = self else { return }
            guard let payload = self.socketService.decode(ParticipantJoinedPayload.self, from: data) else { return }
            
            self.notificationService.scheduleNotification(
                title: "New Participant",
                body: "Alias \(payload.alias) joined room \(payload.roomCode).",
                identifier: UUID().uuidString,
                delay: 0.1
            )
        }
        
        participantLeftId = socketService.on(.participantLeft) { [weak self] data in
            guard let self = self else { return }
            guard let payload = self.socketService.decode(ParticipantLeftPayload.self, from: data) else { return }
            
            self.notificationService.scheduleNotification(
                title: "Participant Left",
                body: "Alias \(payload.alias) left room \(payload.roomCode).",
                identifier: UUID().uuidString,
                delay: 0.1
            )
        }
        
        messageReceiveId = socketService.on(.messageReceive) { [weak self] data in
            guard let self = self else { return }
            guard let payload = self.socketService.decode(MessageReceivePayload.self, from: data) else { return }
            
            self.notificationService.scheduleNotification(
                title: "New Message from \(payload.senderAlias)",
                body: "Open the app to read it securely.",
                identifier: UUID().uuidString,
                delay: 0.1
            )
        }
        
        // Additional events like security alerts or typing could be added here
    }
    
    /// Deja de escuchar los eventos (útil si hay logout o modo no molestar)
    func stopListening() {
        print("[NotificationManager] Stopping socket event observation")
        if let id = participantJoinedId { socketService.off(.participantJoined, id: id) }
        if let id = participantLeftId { socketService.off(.participantLeft, id: id) }
        if let id = messageReceiveId { socketService.off(.messageReceive, id: id) }
        
        participantJoinedId = nil
        participantLeftId = nil
        messageReceiveId = nil
    }
}
