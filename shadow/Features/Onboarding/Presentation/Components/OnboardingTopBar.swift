//
//  OnboardingTopBar.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 4/03/26.
//

import Foundation
import SwiftUI

struct OnboardingTopBar: View {
    let currentStep: Int
    let totalSteps: Int
    let onBack: (() -> Void)?

    var body: some View {
        HStack {
            if let onBack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(.clear)
            }

            Spacer()

            // Page indicator
            Text("\(currentStep)/\(totalSteps)")
                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color.accentYellow)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: currentStep)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.bgPrimary)
        .animation(.easeInOut(duration: 0.3), value: onBack == nil)
    }
}

#Preview {
    OnboardingTopBar(
        currentStep: 1,
        totalSteps: 3,
        onBack: {}
    )
}
