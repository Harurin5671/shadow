//
//  ChatViewModel.swift
//  shadow
//

import Foundation
import SwiftUI
internal import Combine

@Observable
final class ChatViewModel {
    
    // MARK: - Published Properties
    var messages: [RoomMessagePayload] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var messageInput: String = ""
    
    // MARK: - Dependencies
    private let roomCode: String
    private let socketService: SocketServiceProtocol
    private let cryptoManager: CryptoManager
    
    // Listeners
    private var messagesListenerId: UUID?
    private var newMsgListenerId: UUID?
    private var messageSentListenerId: UUID?
    private var errorListenerId: UUID?
    
    private var setupDone = false
    
    init(roomCode: String, socketService: SocketServiceProtocol = DIContainer.shared.socketService, cryptoManager: CryptoManager? = nil) {
        self.roomCode = roomCode
        self.socketService = socketService
        self.cryptoManager = cryptoManager ?? DIContainer.shared.cryptoManager
        // Defer listeners setup to onAppear to avoid side effects during SwiftUI struct initialization
    }
    
    deinit {
        if let id = messagesListenerId { socketService.off(.roomMessages, id: id) }
        if let id = newMsgListenerId { socketService.off(.messageReceive, id: id) }
        if let id = messageSentListenerId { socketService.off(.messageSent, id: id) }
        if let id = errorListenerId { socketService.off(.error, id: id) }
    }
    
    func onAppear() {
        guard !setupDone else { return }
        setupDone = true
        setupListeners()
        fetchMessages()
    }
    
    private func setupListeners() {
        // Listen for history
        messagesListenerId = socketService.on(.roomMessages) { [weak self] data in
            guard let self else { return }
            guard let payload = self.socketService.decode(RoomMessagesPayload.self, from: data) else {
                return
            }
            if payload.roomCode == self.roomCode {
                self.messages = payload.messages
                self.isLoading = false
            }
        }
        
        // Listen for new messages
        newMsgListenerId = socketService.on(.messageReceive) { [weak self] data in
            guard let self else { return }
            guard let payload = self.socketService.decode(MessageReceivePayload.self, from: data) else {
                return
            }
            
            // Evitar duplicar mensajes que ya agregamos localmente
            if !self.messages.contains(where: { $0.id == payload.id }) {
                // Add new message converting to RoomMessagePayload
                let newMsg = RoomMessagePayload(
                    id: payload.id,
                    roomCode: self.roomCode,
                    encryptedPayload: payload.encryptedPayload,
                    senderAlias: payload.senderAlias,
                    sentAt: payload.sentAt,
                    burnAfter: payload.burnAfter
                )
                self.messages.append(newMsg)
            }
        }
        
        // Listen for message sent confirmation
        messageSentListenerId = socketService.on(.messageSent) { [weak self] data in
            guard let self else { return }
            guard let payload = self.socketService.decode(MessageSentPayload.self, from: data) else {
                return
            }
            print("[ChatViewModel] Message sent confirmation received for ID: \(payload.id)")
            // El servidor confirma que recibió el mensaje, pero el mensaje ya se agregó localmente
            // cuando se envió, así que aquí solo podríamos actualizar el estado si fuera necesario
        }
        
        // Listen for errors
        errorListenerId = socketService.on(.error) { [weak self] data in
            guard let self else { return }
            guard let payload = self.socketService.decode(SocketErrorPayload.self, from: data) else { return }
            self.errorMessage = payload.message
            self.isLoading = false
        }
    }
    
    private func fetchMessages() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        socketService.emit(.roomGetMessages, ["roomCode": roomCode])
    }
    
    func sendMessage(message: String, senderAlias: String, burnAfter: Int? = 3600) {
        guard let encryptedPayload = cryptoManager.encryptMessage(message, for: roomCode) else {
            errorMessage = "Failed to encrypt message"
            return
        }
        
        // Generar un ID único para el mensaje
        let messageId = UUID().uuidString
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        // Agregar el mensaje localmente inmediatamente para feedback instantáneo
        let localMessage = RoomMessagePayload(
            id: messageId,
            roomCode: roomCode,
            encryptedPayload: encryptedPayload,
            senderAlias: senderAlias,
            sentAt: timestamp,
            burnAfter: burnAfter ?? 3600
        )
        messages.append(localMessage)
        
        let payload: [String: Any] = [
            "id": messageId,
            "roomCode": roomCode,
            "encryptedPayload": encryptedPayload,
            "senderAlias": senderAlias,
            "burnAfter": burnAfter ?? 3600
        ]
        socketService.emit(.messageSend, payload)
    }
    
    func decryptMessage(_ encryptedPayload: String) -> String? {
        return cryptoManager.decryptMessage(encryptedPayload, for: roomCode)
    }
}
