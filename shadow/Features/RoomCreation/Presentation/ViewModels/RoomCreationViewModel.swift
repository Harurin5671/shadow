//
//  RoomCreationViewModel.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 7/03/26.
//

import Foundation
import SwiftUI

// shadow/Features/RoomCreation/Presentation/ViewModels/RoomCreationViewModel.swift
//
// Maneja los 3 pasos del flujo de creación de sala.
// Equivalente a un ChangeNotifier en Flutter.

@Observable
final class RoomCreationViewModel {

    // MARK: - Paso actual
    enum Step {
        case alias  // Paso 1 — alias + modo anónimo
        case configure  // Paso 2 — configurar sala
        case created  // Paso 3 — sala creada, mostrar código
    }

    var currentStep: Step = .alias

    // MARK: - Paso 1: Alias
    var alias: String = ""
    var isAnonymous: Bool = false

    var aliasIsValid: Bool {
        isAnonymous
            || (!alias.trimmingCharacters(in: .whitespaces).isEmpty
                && alias.count <= 20)
    }

    var displayAlias: String {
        isAnonymous
            ? Self.generateRandomAlias()
            : alias.trimmingCharacters(in: .whitespaces)
    }

    // MARK: - Paso 2: Configuración
    var maxParticipants: Int = 10

    // Contraseña
    var passwordEnabled: Bool = false
    var password: String = ""

    // Dead man's switch
    var deadManEnabled: Bool = false
    var deadManInterval: DeadManInterval = .tenMin

    // Burn timer por defecto
    var burnTimerEnabled: Bool = false
    var burnTimer: BurnTimer = .thirtySeconds

    // Modo fantasma
    var ghostModeEnabled: Bool = false

    // MARK: - Paso 3: Sala creada
    var roomCode: String = ""
    var roomFingerprint: [String] = []  // 8 emojis
    var mySocketId: String = ""

    // MARK: - Estado de carga y error
    var isLoading: Bool = false
    var errorMessage: String? = nil

    // MARK: - Socket
    private let socket = SocketService.shared

    var onDismiss: (() -> Void)?

    // MARK: - Paso 1 → 2

    func goToConfigure() {
        guard aliasIsValid else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStep = .configure
        }
    }

    func goBackToAlias() {
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStep = .alias
        }
    }

    // MARK: - Paso 2 → 3: Crear sala en el servidor

    func createRoom() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        // Escuchar respuesta del servidor
        socket.on(.roomCreated) { [weak self] data in
            guard let self else { return }
            guard
                let payload = self.socket.decode(
                    RoomCreatedPayload.self,
                    from: data
                )
            else {
                self.isLoading = false
                self.errorMessage = "Could not create room. Try again."
                return
            }

            self.roomCode = payload.code
            self.mySocketId = payload.socketId
            self.roomFingerprint = Self.generateFingerprint(from: payload.code)
            self.isLoading = false

            withAnimation(.easeInOut(duration: 0.25)) {
                self.currentStep = .created
            }
        }

        // Emitir evento al servidor
        var roomData: [String: Any] = [
            "alias": displayAlias,
            "maxParticipants": maxParticipants,
        ]

        if passwordEnabled && !password.isEmpty {
            roomData["password"] = password
        }
        if deadManEnabled {
            roomData["deadManSwitchInterval"] = deadManInterval.seconds
        }
        if burnTimerEnabled {
            roomData["defaultBurnAfter"] = burnTimer.seconds
        }

        socket.emit(.roomCreate, roomData)
    }

    func dismiss() {
        onDismiss?()
    }

    // MARK: - Helpers

    // Alias aleatorio para modo anónimo
    // Adjetivo + Animal en inglés
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

    // Genera 8 emojis desde el código de sala como huella visual
    // Permite verificar que no hay MITM — todos deben ver los mismos
    private static func generateFingerprint(from code: String) -> [String] {
        let emojis = [
            "🔐", "🛡️", "⚡", "🌑", "🔮", "💀", "🕷️", "🗝️",
            "🌊", "🔥", "❄️", "⚔️", "🎯", "🧬", "🔬", "💎",
            "🌪️", "🦅", "🐺", "🦊", "🐍", "🦁", "🐉", "🦂",
        ]
        var result: [String] = []
        var seed = code.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        for _ in 0..<8 {
            seed = (seed * 1_103_515_245 + 12345) & 0x7fff_ffff
            result.append(emojis[seed % emojis.count])
        }
        return result
    }
}

// MARK: - Enums de configuración

enum DeadManInterval: Int, CaseIterable, Identifiable {
    case twoMin = 2
    case fiveMin = 5
    case tenMin = 10
    case fifteenMin = 15
    case thirtyMin = 30
    case sixtyMin = 60

    var id: Int { rawValue }
    var seconds: Int { rawValue * 60 }

    var label: String {
        switch self {
        case .twoMin: return "2 MIN"
        case .fiveMin: return "5 MIN"
        case .tenMin: return "10 MIN"
        case .fifteenMin: return "15 MIN"
        case .thirtyMin: return "30 MIN"
        case .sixtyMin: return "60 MIN"
        }
    }
}

enum BurnTimer: Int, CaseIterable, Identifiable {
    case tenSeconds = 10
    case thirtySeconds = 30
    case oneMin = 60
    case fiveMin = 300

    var id: Int { rawValue }
    var seconds: Int { rawValue }

    var label: String {
        switch self {
        case .tenSeconds: return "10 SEC"
        case .thirtySeconds: return "30 SEC"
        case .oneMin: return "1 MIN"
        case .fiveMin: return "5 MIN"
        }
    }
}
