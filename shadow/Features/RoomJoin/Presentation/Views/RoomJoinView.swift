//
//  RoomJoinView.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 6/03/26.
//

import SwiftUI

struct RoomJoinView: View {

    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            Text("Hello RoomJoin")
                .foregroundStyle(Color.textPrimary)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.textPrimary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RoomJoinView()
            .environment(AppRouter())
    }
}
