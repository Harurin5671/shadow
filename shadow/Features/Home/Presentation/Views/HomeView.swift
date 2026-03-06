//
//  HomeView.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 3/03/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Color.bgPrimary
                .ignoresSafeArea()
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
        }
        .safeAreaInset(edge: .top) {
            HomeTopBar()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                AppButton(
                    label: LocalizedStringKey("home.action.create_room"),
                    action: {},
                    layout: .center,
                    leadingIcon: "plus"
                )

                AppButton(
                    label: LocalizedStringKey("home.action.join_with_code"),
                    action: {},
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
    }
}

#Preview {
    HomeView()
}
