//
//  RoomJoinViewModel.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 8/03/26.
//

import CryptoKit
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
    private var timeoutTask: Task<Void, Never>?
    private var listenersSetup = false

    init(
        socketService: SocketServiceProtocol = DIContainer.shared.socketService
    ) {
        self.socketService = socketService
        // No llamar a setupListeners() aquí para evitar múltiples registros
    }

    deinit {
        timeoutTask?.cancel()
        if let id = joinListenerId { socketService.off(.roomJoined, id: id) }
        if let id = errorListenerId { socketService.off(.error, id: id) }
    }

    // MARK: - Unirse a la sala

    private func setupListeners() {
        guard !listenersSetup else { return }
        listenersSetup = true
        
        joinListenerId = socketService.on(.roomJoined) { [weak self] data in
            guard let self else { return }
            guard
                let payload = self.socketService.decode(
                    RoomJoinedPayload.self,
                    from: data
                )
            else {
                self.isLoading = false
                self.errorMessage = "Could not join room. Try again."
                return
            }

            // Cancelar timeout si la unión es exitosa
            self.timeoutTask?.cancel()
            self.timeoutTask = nil

            if let creatorPublicKeyB64 = payload.creator?.publicKey,
                let creatorPublicKeyData = Data(
                    base64Encoded: creatorPublicKeyB64
                )
            {
                StorageService.shared.saveToKeychain(
                    creatorPublicKeyData,
                    forKey: .publicKey(payload.creator?.socketId ?? "creator")
                )
            }

            DIContainer.shared.cryptoManager.setupAsParticipant(
                for: payload.code,
                alias: self.alias,
                creatorSocketId: payload.creator?.socketId,
                creatorPublicKeyB64: payload.creator?.publicKey
            )

            self.isLoading = false
            self.joinedRoomCode = payload.code
            self.shouldNavigateToChat = true
        }

        errorListenerId = socketService.on(.error) { [weak self] data in
            guard let self else { return }
            guard
                let payload = self.socketService.decode(
                    SocketErrorPayload.self,
                    from: data
                )
            else { return }
            
            // Cancelar timeout si recibimos error
            self.timeoutTask?.cancel()
            self.timeoutTask = nil
            
            self.isLoading = false
            self.errorMessage = payload.message
        }
    }

    func joinRoom() {
        guard canJoin, !isLoading else { return }
        
        // Setup listeners solo cuando se va a unir a la sala
        if !listenersSetup {
            setupListeners()
        }
        
        isLoading = true
        errorMessage = nil

        // Cancelar timeout anterior si existe
        timeoutTask?.cancel()
        
        // Configurar timeout de 10 segundos
        timeoutTask = Task {
            try? await Task.sleep(nanoseconds: 10_000_000_000) // 10 segundos
            if !Task.isCancelled {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Room not found or server timeout. Please check the code and try again."
                }
            }
        }

        let finalAlias =
            alias.trimmingCharacters(in: .whitespaces).isEmpty
            ? Self.generateRandomAlias()
            : alias.trimmingCharacters(in: .whitespaces)

        let cryptoManager = DIContainer.shared.cryptoManager
        let privateKey =
            CryptoService.shared.loadPrivateKey()
            ?? CryptoService.shared.generatePrivateKey()
        _ = CryptoService.shared.savePrivateKey(privateKey)
        let publicKeyData = CryptoService.shared.encodePublicKey(
            privateKey.publicKey
        )
        let publicKeyBase64 = publicKeyData.base64EncodedString()

        socketService.emit(
            .roomJoin,
            [
                "roomCode": roomCode.uppercased(),
                "alias": finalAlias,
                "isGhost": isGhost,
                "publicKey": publicKeyBase64,
            ]
        )

        self.alias = finalAlias
    }

    private static func generateRandomAlias() -> String {
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
