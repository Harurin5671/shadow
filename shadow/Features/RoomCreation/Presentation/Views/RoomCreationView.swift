//
//  RoomCreationView.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 6/03/26.
//

import SwiftUI

struct RoomCreationView: View {

    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Hello RoomCreation")
                    .foregroundStyle(Color.textPrimary)

                Button("Cerrar") {
                    router.dismissRoomCreation()
                }
                .foregroundStyle(Color.accentYellow)
            }
        }
    }
}

#Preview {
    RoomCreationView()
        .environment(AppRouter())
}
