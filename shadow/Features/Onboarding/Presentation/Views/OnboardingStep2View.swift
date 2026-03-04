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
        }
    }
}

#Preview {
    OnboardingStep2View(
        onNext: {},
        onPreview: {}
    )
}
