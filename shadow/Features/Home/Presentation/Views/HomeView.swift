//
//  HomeView.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 3/03/26.
//

import SwiftUI

struct HomeView: View {
    @Environment(AppRouter.self) private var router: AppRouter
    @Environment(SocketService.self) private var socket: SocketService
    @State private var viewModel: HomeViewModel
    
    init() {
        _viewModel = State(initialValue: HomeViewModel(
            roomRepository: DIContainer.shared.roomRepository,
            socketService: DIContainer.shared.socketService
        ))
    }
    
    // Estado para el tiempo restante de cada sala
    @State private var roomTimes: [String: Int] = [:]
    @State private var timer: Timer?
    
    private func formatLastActive(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = formatter.date(from: dateString) {
            let now = Date()
            let interval = now.timeIntervalSince(date)
            
            if interval < 3600 { // Less than 1 hour
                let minutes = Int(interval / 60)
                return "active \(minutes)m ago"
            } else if interval < 86400 { // Less than 1 day
                let hours = Int(interval / 3600)
                return "active \(hours)h ago"
            } else {
                let days = Int(interval / 86400)
                return "active \(days)d ago"
            }
        }
        
        return "active recently"
    }
    
    private func formatTimeRemaining(_ seconds: Int) -> String {
        if seconds <= 0 {
            return "EXPIRED"
        }
        
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Actualizar el tiempo restante para cada sala
            for (roomCode, remainingSeconds) in roomTimes {
                if remainingSeconds > 0 {
                    roomTimes[roomCode] = remainingSeconds - 1
                } else {
                    // Si expira, remover de la lista
                    roomTimes.removeValue(forKey: roomCode)
                    // También remover del viewModel
                    viewModel.removeRoom(withCode: roomCode)
                }
            }
        }
    }
    
    private func updateRoomTimes() {
        var newTimes: [String: Int] = [:]
        
        for room in viewModel.rooms {
            if room.expiresInSeconds > 0 {
                newTimes[room.code] = room.expiresInSeconds
            }
        }
        
        roomTimes = newTimes
        
        // Iniciar timer si hay salas con tiempo
        if !roomTimes.isEmpty && timer == nil {
            startTimer()
        } else if roomTimes.isEmpty {
            timer?.invalidate()
            timer = nil
        }
    }
    
    var body: some View {
        ZStack {
            Color.bgPrimary
                .ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.rooms.isEmpty {
                // Loading state
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.accentYellow))
                        .scaleEffect(1.2)
                    
                    Text("Loading your rooms...")
                        .textStyle(.monoMicro, family: .jetbrainsRegular)
                        .foregroundStyle(Color.textMuted)
                }
                .frame(maxHeight: .infinity, alignment: .center)
            } else if viewModel.rooms.isEmpty {
                // Empty state - existing UI
                VStack(spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#E7FF47").opacity(0.05))
                            .blur(radius: 24)

                        Image(systemName: "lock")
                            .resizable()
                            .scaledToFit()
                            .fontWeight(.thin)
                            .foregroundStyle(Color(hex: "#2A2D1F"))
                    }
                    .frame(width: 128, height: 128)

                    Spacer().frame(height: 32)

                    Text(LocalizedStringKey("home.empty.title"))
                        .textStyle(.displaySmall, family: .jetbrainsRegular)

                    Spacer().frame(height: 12)

                    Text.localized("home.empty.description").textStyle(
                        .monoMicro,
                        family: .jetbrainsRegular,
                        color: .color(Color.white.opacity(0.4)),
                        alignment: .center
                    )
                }
                .frame(maxHeight: .infinity, alignment: .center)
            } else {
                // Rooms list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.rooms) { room in
                            ActiveRoomCard(
                                roomCode: room.code,
                                participantCount: room.participantCount,
                                lastActive: formatLastActive(room.createdAt),
                                timeRemaining: roomTimes[room.code] != nil ? formatTimeRemaining(roomTimes[room.code]!) : nil,
                                isEncrypted: true, // Todas las salas son encriptadas
                                onTap: {
                                    print("[HomeView] Tapped room: \(room.code)")
                                    viewModel.setCurrentRoom(room.code)
                                    router.goToChat(roomCode: room.code)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }
        }
        .safeAreaInset(edge: .top) {
            HomeTopBar()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                AppButton(
                    label: LocalizedStringKey("home.action.create_room"),
                    action: { 
                        print("[HomeView] Create room button tapped")
                        router.showRoomCreation() 
                    },
                    layout: .center,
                    leadingIcon: "plus"
                )

                AppButton(
                    label: LocalizedStringKey("home.action.join_with_code"),
                    action: { router.goToRoomJoin() },
                    layout: .center,
                    leadingIcon: "qrcode",
                    foregroundColor: .white,
                    backgroundColor: .clear,
                    uppercase: true,
                    borderColor: .white.opacity(0.2),
                    borderWidth: 1
                )

                // Conexión cifrada activa
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: "#47FFE8"))
                        .frame(width: 6, height: 6)
                    Text(
                        LocalizedStringKey("home.security.encrypted_connection")
                    )
                    .textStyle(
                        .monoMicro,
                        family: .jetbrainsRegular,
                        color: .color(Color(hex: "#47FFE8")),
                        uppercase: true
                    )
                }
            }
            .padding(.horizontal, 24)
        }
        .onReceive(NotificationCenter.default.publisher(for: .roomCreated)) { notification in
            print("[HomeView] Received room created notification")
            
            // Si la notificación incluye datos de la sala, mostrarla inmediatamente
            if let newRoom = notification.object as? RoomInfo {
                print("[HomeView] Adding new room immediately: \(newRoom.code) with expires in \(newRoom.expiresInSeconds)s")
                // Agregar la sala inmediatamente para feedback instantáneo
                if !viewModel.rooms.contains(where: { $0.code == newRoom.code }) {
                    viewModel.insertRoom(newRoom, at: 0) // Insertar al principio
                    // Actualizar tiempos inmediatamente
                    if newRoom.expiresInSeconds > 0 {
                        roomTimes[newRoom.code] = newRoom.expiresInSeconds
                    }
                }
            }
            
            // También refrescar desde el servidor después de un delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("[HomeView] Refreshing rooms from server after delay...")
                viewModel.loadMyRooms()
            }
        }
        .onChange(of: socket.isConnected) { oldValue, newValue in
            print("[HomeView] Socket connection changed: \(oldValue) -> \(newValue)")
            if newValue {
                // Socket se conectó, verificar si necesitamos cargar salas
                viewModel.checkConnectionAndLoad()
            }
        }
        .onAppear {
            print("[HomeView] onAppear - updating room times")
            updateRoomTimes()
            viewModel.onAppear()
        }
        .onChange(of: viewModel.rooms) { oldValue, newValue in
            print("[HomeView] Rooms changed from \(oldValue.count) to \(newValue.count)")
            updateRoomTimes()
        }
        .onDisappear {
            print("[HomeView] onDisappear - cleaning up timer")
            timer?.invalidate()
            timer = nil
            viewModel.onDisappear()
        }
    }
}

struct ActiveRoomCard: View {
    
    let roomCode: String
    let participantCount: Int
    let lastActive: String
    let timeRemaining: String? // nil si no hay timer
    let isEncrypted: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .leading) {
                
                // Card background
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.bgSurface)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.borderDefault, lineWidth: 1)
                    }
                
                // Left accent bar
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.accentYellow)
                        .frame(width: 6)
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Content
                HStack(alignment: .center) {
                    
                    // Left — room code + meta
                    VStack(alignment: .leading, spacing: 6) {
                        
                        // Room code + encrypted icon
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(roomCode)
                                .textStyle(
                                    .displayMedium,
                                    family: .syne,
                                    color: .color(Color.accentYellow),
                                    uppercase: true
                                )
                            
                            if isEncrypted {
                                Image(systemName: "lock.shield")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.textMuted)
                            }
                        }
                        
                        // Participants + last active
                        HStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Image(systemName: "person.2")
                                    .font(.system(size: 12))
                                Text("\(participantCount)")
                                    .textStyle(.monoMicro, family: .jetbrainsRegular)
                            }
                            .foregroundStyle(Color.textMuted)
                            
                            Circle()
                                .fill(Color.textMuted)
                                .frame(width: 4, height: 4)
                            
                            Text(lastActive)
                                .textStyle(.monoMicro, family: .jetbrainsRegular)
                                .foregroundStyle(Color.textMuted)
                        }
                    }
                    
                    Spacer()
                    
                    // Right — timer + arrow
                    VStack(alignment: .trailing, spacing: 8) {
                        
                        // Timer
                        if let time = timeRemaining {
                            HStack(spacing: 4) {
                                Image(systemName: "timer")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.danger)
                                
                                Text(time)
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundStyle(Color.danger)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.danger.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textMuted)
                    }
                }
                .padding(.vertical, 20)
                .padding(.leading, 28)
                .padding(.trailing, 20)
            }
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    HomeView()
        .environment(AppRouter())
        .environment(DIContainer.shared.socketService)
}
