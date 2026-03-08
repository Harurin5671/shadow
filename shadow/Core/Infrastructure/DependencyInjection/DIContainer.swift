//
//  DIContainer.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 8/03/26.
//

import Foundation
import SwiftUI

/// Simple Dependency Injection container to provide shared resources
@Observable
final class DIContainer {
    static let shared = DIContainer()
    
    let socketService: SocketService
    let roomRepository: RoomRepository
    let localNotificationService: LocalNotificationServiceProtocol
    let notificationManager: NotificationManager
    
    private init() {
        self.socketService = SocketService.shared
        self.roomRepository = RoomRepository(socketService: self.socketService)
        self.localNotificationService = LocalNotificationService()
        self.notificationManager = NotificationManager(
            socketService: self.socketService,
            notificationService: self.localNotificationService
        )
        
        // Empezar a escuchar las notificaciones en el manager central
        self.notificationManager.startListening()
    }
}

