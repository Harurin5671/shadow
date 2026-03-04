//
//  OnboardingStep1View.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 3/03/26.
//

import SwiftUI

struct OnboardingStep1View: View {
    let onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StackedCardIcon()
            .frame(maxWidth: .infinity)
            .frame(height: 240)
            .padding(.top, 32)

            VStack(alignment: .leading, spacing: 16) {

                Text.localized("onboarding.step1.headline")
                    .textStyle(
                        .displayLarge,
                        family: .spaceGrotesk,
                        uppercase: true,
                        size: 36,
                    )

                Text.localized("onboarding.step1.subtitle").textStyle(
                    .monoBody,
                    family: .jetbrains,
                    color: .color(Color(hex: "#94A3B8")),
                    size: 14
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)

            Spacer().frame(height: 48)

            OnboardingProgressBar(current: 1, total: 3)

            Spacer().frame(height: 24)

            OnboardingCTAButton(step: 1, totalSteps: 3, action: onNext)
        }
    }
}

#Preview {
    OnboardingStep1View(onNext: {})
}
