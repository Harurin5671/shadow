//
//  RoomJoinViewModel.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 8/03/26.
//

import Foundation

@Observable
final class RoomJoinViewModel {

    // MARK: - Inputs
    var roomCode: String = ""
    var alias: String = ""
    var isGhost: Bool = false

    // MARK: - Estado
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var shouldNavigateToChat: Bool = false
    var joinedRoomCode: String? = nil

    var canJoin: Bool {
        roomCode.count == 4
    }

    // MARK: - Dependencies
    private let socketService: SocketServiceProtocol
    
    // Listeners
    private var joinListenerId: UUID?
    private var errorListenerId: UUID?

    init(socketService: SocketServiceProtocol = DIContainer.shared.socketService) {
        self.socketService = socketService
        setupListeners()
    }
    
    deinit {
        if let id = joinListenerId { socketService.off(.roomJoined, id: id) }
        if let id = errorListenerId { socketService.off(.error, id: id) }
    }



    // MARK: - Unirse a la sala

    private func setupListeners() {
        joinListenerId = socketService.on(.roomJoined) { [weak self] data in
            guard let self else { return }
            guard let payload = self.socketService.decode(RoomJoinedPayload.self, from: data) else {
                self.isLoading = false
                self.errorMessage = "Could not join room. Try again."
                return
            }
            self.isLoading = false
            self.joinedRoomCode = payload.code
            self.shouldNavigateToChat = true
        }

        errorListenerId = socketService.on(.error) { [weak self] data in
            guard let self else { return }
            guard let payload = self.socketService.decode(SocketErrorPayload.self, from: data) else { return }
            self.isLoading = false
            self.errorMessage = payload.message
        }
    }

    func joinRoom() {
        guard canJoin, !isLoading else { return }
        isLoading = true
        errorMessage = nil

        let finalAlias = alias.trimmingCharacters(in: .whitespaces).isEmpty
            ? Self.generateRandomAlias()
            : alias.trimmingCharacters(in: .whitespaces)

        socketService.emit(.roomJoin, [
            "roomCode": roomCode.uppercased(),
            "alias": finalAlias,
            "isGhost": isGhost,
        ])
    }

    private static func generateRandomAlias() -> String {
        let adjectives = ["Silent", "Ghost", "Dark", "Void", "Phantom",
                          "Shadow", "Cipher", "Null", "Echo", "Binary"]
        let nouns = ["Fox", "Wolf", "Raven", "Viper", "Hawk",
                     "Lynx", "Crow", "Owl", "Bear", "Shark"]
        return "\(adjectives.randomElement()!)\(nouns.randomElement()!)"
    }
}
