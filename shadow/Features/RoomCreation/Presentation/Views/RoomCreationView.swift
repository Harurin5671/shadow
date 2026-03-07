//
//  RoomCreationView.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 6/03/26.
//

import SwiftUI

struct RoomCreationView: View {

    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var vm = RoomCreationViewModel()

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            switch vm.currentStep {
            case .alias:
                RoomCreationAliasView(vm: vm)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .leading)
                        )
                    )
            case .configure:
                RoomCreationConfigView(vm: vm)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .trailing)
                        )
                    )
            case .created:
                RoomCreatedView(
                    vm: vm,
                    onDone: {
                        router.dismissRoomCreation()
                        // router.goToChat(roomCode: vm.roomCode)
                    }
                )
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                    )
                )
            }
        }
        .animation(.easeInOut(duration: 0.25), value: vm.currentStep)
        .onAppear {
            vm.onDismiss = { dismiss() }
        }
    }
}

#Preview {
    RoomCreationView()
        .environment(AppRouter())
}
