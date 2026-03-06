//
//  OnboardingStep3View.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 3/03/26.
//

import SwiftUI

struct OnboardingStep3View: View {
    let onFinished: () -> Void
    let onPreview: () -> Void

    var body: some View {
        VStack {
            StackedCardIcon(icon: .system("eye.slash.fill"))
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .padding(.top, 32)

            Spacer()
                .frame(height: 32)

            Text.localized("onboarding.step3.title")
                .textStyle(
                    .displayLarge,
                    family: .spaceGrotesk,
                    alignment: .center
                )

            Spacer()
                .frame(height: 16)

            Text.localized(
                "onboarding.step3.subtitle"
            )
            .textStyle(
                .labelLarge,
                family: .spaceGroteskRegular,
                color: .color(Color(hex: "#94A3B8")),
                alignment: .center
            )

            Spacer()
                .frame(height: 24)

            OnboardingProgressBar(current: 3, total: 3)

            Spacer()
                .frame(height: 24)

            AppButton(
                label: LocalizedStringKey("onboarding.step.finishBtn"),
                action: onFinished,
                trailingIcon: "checkmark"
            )

        }
    }
}

#Preview {
    OnboardingStep3View(
        onFinished: {},
        onPreview: {}
    )
}
