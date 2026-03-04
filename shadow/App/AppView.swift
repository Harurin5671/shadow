//
//  AppView.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 1/03/26.
//

import SwiftUI

struct AppView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        Group {
            switch router.currentScreen {
            case .onboarding:
                OnboardingView()
                    .transition(.opacity)
            case .main:
                HomeView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: router.currentScreen)
    }
}

#Preview {
    AppView()
}
