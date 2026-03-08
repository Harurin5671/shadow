//
//  HomeViewModel.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 8/03/26.
//

import Foundation
import SwiftUI

@Observable
final class HomeViewModel {
    
    var rooms: [RoomInfo] = []
    var isLoading: Bool = false

    private let socket = SocketService.shared

    init() {
        setupListeners()
        loadMyRooms()
    }
    
    private func setupListeners() {
        socket.on(.myRooms) { [weak self] data in
            guard let self else { return }
            guard let payload = socket.decode(MyRoomsPayload.self, from: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self.rooms = payload.rooms
                self.isLoading = false
            }
        }
    }
    
    func loadMyRooms() {
        isLoading = true
        socket.emit(.roomGetMyRooms, [:])
    }
}

