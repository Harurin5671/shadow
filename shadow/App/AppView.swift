//
//  AppView.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 1/03/26.
//

import SwiftUI

struct AppView: View {
    @Environment(AppRouter.self) private var router
    @State private var homeViewModel = HomeViewModel.shared
    private let socket = SocketService.shared

    var body: some View {
        @Bindable var router = router

        Group {
            if !socket.isConnected {
                NoConnectionView(onRetry: {
                    SocketService.shared.connect()
                })
                .transition(.opacity)
            } else {
                switch router.currentScreen {
                case .onboarding:
                    OnboardingView()
                        .transition(.opacity)
                case .main:
                    NavigationStack(path: $router.navigationPath) {
                        HomeView()
                            .navigationDestination(
                                for: AppRouter.Destination.self
                            ) { dest in
                                switch dest {
                                case .roomJoin:
                                    RoomJoinView()
                                case .chat(let roomCode):
                                    ChatView(roomCode: roomCode)
                                case .settings:
                                    SettingsView()
                                }
                            }
                    }
                    .sheet(isPresented: $router.isShowingRoomCreation) {
                        RoomCreationView()
                    }
                    .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: socket.isConnected)
        .animation(.easeInOut(duration: 0.35), value: router.currentScreen)
        .environment(SocketService.shared)
    }
}

#Preview {
    AppView()
        .environment(AppRouter())
}
