//
//  HomeTopBar.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 6/03/26.
//

import Foundation
import SwiftUI

struct HomeTopBar: View {
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey("Shadow"))
                    .textStyle(
                        .displayLarge,
                        color: .color(.accentYellow),
                        uppercase: true
                    )

                HStack {
                    Circle()
                        .frame(width: 6, height: 6)
                        .foregroundStyle(.accentYellow)

                    Text("home.topbar.security_features")
                        .textStyle(
                            .monoMicro,
                            family: .jetbrainsRegular
                        )
                }
            }

            Spacer()

            Button {
                router.goToSettings()
            } label: {
                Image("settings")
            }
        }
        .padding(.horizontal, 24)
    }
}
