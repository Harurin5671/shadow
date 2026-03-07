//
//  NoConnectionView.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 7/03/26.
//

import SwiftUI

struct NoConnectionView: View {

    let onRetry: () -> Void

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 16) {
                Text("NO CONNECTION")
                    .foregroundStyle(Color.danger)

                Text("Shadow requires an encrypted connection to operate.")
                    .foregroundStyle(Color.textMuted)

                Button("RETRY") {
                    onRetry()
                }
                .foregroundStyle(Color.accentYellow)
            }
        }
    }
}

#Preview {
    NoConnectionView(onRetry: {})
}
