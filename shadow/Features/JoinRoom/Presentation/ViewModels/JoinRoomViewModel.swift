//
//  JoinRoomViewModel.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 10/03/26.
//

import Foundation
import SwiftUI

@Observable
final class JoinRoomViewModel {

    // MARK: - Properties
    var roomCode: String = ""
    var alias: String = ""
    var isAnonymous: Bool = false
    var password: String = ""
    var passwordRequired: Bool = false

    var isLoading: Bool = false
    var errorMessage: String? = nil
    var joinSuccess: Bool = false

    // MARK: - Dependencies
    private let socketService: SocketServiceProtocol
    private let cryptoManager: CryptoManager
    private var roomJoinedHandlerId: UUID?
    private var errorHandlerId: UUID?

    init(
        socketService: SocketServiceProtocol = DIContainer.shared.socketService,
        cryptoManager: CryptoManager? = nil
    ) {
        self.socketService = socketService
        self.cryptoManager = cryptoManager ?? DIContainer.shared.cryptoManager
    }

    var onJoinSuccess: ((RoomJoinedPayload) -> Void)?
    var onDismiss: (() -> Void)?

    deinit {
        if let id = roomJoinedHandlerId {
            socketService.off(.roomJoined, id: id)
        }
        if let id = errorHandlerId { socketService.off(.error, id: id) }
    }

    // MARK: - Validation
    var roomCodeValid: Bool {
        !roomCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var aliasValid: Bool {
        isAnonymous
            || !alias.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canJoin: Bool {
        roomCodeValid && aliasValid && !isLoading
    }

    var displayAlias: String {
        if isAnonymous {
            return generateRandomAlias()
        }
        return alias.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Join Room
    func joinRoom() {
        guard canJoin else {
            print("[JoinRoomViewModel] Cannot join room - validation failed")
            return
        }

        print("[JoinRoomViewModel] Joining room \(roomCode) as \(displayAlias)")
        isLoading = true
        errorMessage = nil
        joinSuccess = false

        setupListeners()

        var joinData: [String: Any] = [
            "roomCode": roomCode.trimmingCharacters(in: .whitespacesAndNewlines)
                .uppercased(),
            "alias": displayAlias,
            "isGhost": false,
        ]

        if passwordRequired && !password.isEmpty {
            joinData["password"] = password
        }

        socketService.emit(.roomJoin, joinData)
    }

    private func setupListeners() {
        // Clean up existing listeners
        if let id = roomJoinedHandlerId {
            socketService.off(.roomJoined, id: id)
            roomJoinedHandlerId = nil
        }
        if let id = errorHandlerId {
            socketService.off(.error, id: id)
            errorHandlerId = nil
        }

        // Listen for successful join
        roomJoinedHandlerId = socketService.on(.roomJoined) {
            [weak self] data in
            guard let self = self else { return }

            guard
                let payload = self.socketService.decode(
                    RoomJoinedPayload.self,
                    from: data
                )
            else {
                print("[JoinRoomViewModel] Failed to decode RoomJoinedPayload")
                self.isLoading = false
                self.errorMessage = "Failed to join room. Please try again."
                return
            }

            print(
                "[JoinRoomViewModel] Successfully joined room \(payload.code)"
            )

            // Setup crypto como participant
            self.cryptoManager.setupAsParticipant(
                for: payload.code,
                alias: self.displayAlias,
                creatorSocketId: payload.creator?.socketId,
                creatorPublicKeyB64: payload.creator?.publicKey
            )

            self.isLoading = false
            self.joinSuccess = true
            self.onJoinSuccess?(payload)
        }

        // Listen for errors
        errorHandlerId = socketService.on(.error) { [weak self] data in
            guard let self = self else { return }

            guard
                let payload = self.socketService.decode(
                    SocketErrorPayload.self,
                    from: data
                )
            else {
                self.isLoading = false
                self.errorMessage = "An unknown error occurred"
                return
            }

            print("[JoinRoomViewModel] Error joining room: \(payload.message)")
            self.isLoading = false
            self.errorMessage = payload.message

            // Check if password is required
            if payload.code == "INVALID_PASSWORD" {
                self.passwordRequired = true
            }
        }
    }

    func dismiss() {
        if let id = roomJoinedHandlerId {
            socketService.off(.roomJoined, id: id)
            roomJoinedHandlerId = nil
        }
        if let id = errorHandlerId {
            socketService.off(.error, id: id)
            errorHandlerId = nil
        }
        onDismiss?()
    }

    // MARK: - Helpers
    private func generateRandomAlias() -> String {
        let adjectives = [
            "Silent", "Ghost", "Dark", "Void", "Phantom",
            "Shadow", "Cipher", "Null", "Echo", "Binary",
        ]
        let nouns = [
            "Fox", "Wolf", "Raven", "Viper", "Hawk",
            "Lynx", "Crow", "Owl", "Bear", "Shark",
        ]
        return "\(adjectives.randomElement()!)\(nouns.randomElement()!)"
    }
}
