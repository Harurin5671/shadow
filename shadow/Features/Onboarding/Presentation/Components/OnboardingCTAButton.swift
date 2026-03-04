//
//  OnboardingCTAButton.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 4/03/26.
//

import Foundation
import SwiftUI

struct OnboardingCTAButton: View {

    let labelKey: String
    let isLast: Bool
    let action: () -> Void

    init(
        step: Int,
        totalSteps: Int,
        action: @escaping () -> Void
    ) {
        self.isLast = step == totalSteps
        self.labelKey = isLast
            ? "onboarding.step.finishBtn"
            : "onboarding.step.nextBtn"
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Text(LocalizedStringKey(labelKey))
                    .textStyle(
                        .monoBody,
                        family: .spaceGrotesk,
                        color: .color(Color(hex: "#0F172A")),
                        uppercase: true
                    )

                Spacer()

                Image(systemName: isLast ? "checkmark" : "arrow.right")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "#0F172A"))
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.accentYellow)
        }
    }
}
