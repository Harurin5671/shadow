//
//  OnboardingStep2View.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 3/03/26.
//

import SwiftUI

struct OnboardingStep2View: View {
    let onNext: () -> Void
    let onPreview: () -> Void

    var body: some View {
        VStack {
            Image("IllustrationContainer")
                .resizable()
                .scaledToFit()
                .frame(width: 320, height: 320)

            Spacer()
                .frame(height: 32)

            HStack {
                Image("timer_off")

                Text("onboarding.step2.badge")
                    .textStyle(
                        .monoBody,
                        family: .spaceGrotesk,
                        color: .color(Color(hex: "#FF4747")),
                        uppercase: true
                    )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color(hex: "#FF4747").opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.danger.opacity(0.3), lineWidth: 1)
            )

            Spacer().frame(height: 24)

            Text("onboarding.step2.title.line1")
                .textStyle(.displayLarge, family: .spaceGrotesk)

            Text("onboarding.step2.title.line2")
                .textStyle(
                    .displayLarge,
                    family: .spaceGrotesk,
                    color: .linear(
                        LinearGradient(
                            colors: [
                                Color(hex: "#FF4747"), Color(hex: "#E7FF47"),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                )
                .multilineTextAlignment(.center)

            Spacer().frame(height: 16)

            Text.localized("onboarding.step2.subtitle")
                .textStyle(
                    .labelLarge,
                    family: .spaceGroteskRegular,
                    color: .color(Color(hex: "#94A3B8")),
                    alignment: .center
                )

            Spacer().frame(height: 24)

            OnboardingProgressBar(current: 2, total: 3)

            Spacer().frame(height: 32)
            
            AppButton(
                label: LocalizedStringKey("onboarding.step.nextBtn"),
                action: onNext,
                trailingIcon: "arrow.right"
            )
        }
    }
}

#Preview {
    OnboardingStep2View(
        onNext: {},
        onPreview: {}
    )
}
