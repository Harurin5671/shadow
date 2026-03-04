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
            ZStack(alignment: .center) {
                // Rectángulo de atrás - rotado -12°
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "#E7FF47").opacity(0.05))
                    .frame(width: 192, height: 192)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(
                                Color(hex: "#E7FF47").opacity(0.6),
                                lineWidth: 1
                            )
                    )
                    .rotationEffect(.degrees(-12))

                // Rectángulo del medio - rotado 6°
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "#E7FF47").opacity(0.05))
                    .frame(width: 192, height: 192)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(
                                Color(hex: "#E7FF47").opacity(0.6),
                                lineWidth: 1
                            )
                    )
                    .rotationEffect(.degrees(6))

                // Rectángulo frontal
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "#21230F").opacity(0.50))
                    .frame(width: 160, height: 160)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(
                                Color(hex: "#E7FF47").opacity(1.0),
                                lineWidth: 2
                            )
                    )

                // Ícono del candado
                Image(systemName: "lock.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Color(hex: "#E7FF47"))
            }
            .frame(maxWidth: .infinity)  // 👈 esto lo centra
            .frame(height: 240)  // 👈 altura fija para que no colapse
            .padding(.top, 32)

            VStack(alignment: .leading, spacing: 16) {

                Text(
                    """
                    Ningún servidor
                    lee tus
                    mensajes.
                    """
                )
                .textStyle(
                    .displayLarge,
                    family: .spaceGrotesk,
                    uppercase: true,
                    size: 36,
                )

                Text(
                    "Tu clave de cifrado nunca sale de tu dispositivo. Solo los presentes en la sala pueden leer — ni el servidor, ni Apple, ni nadie externo."
                ).textStyle(
                    .monoBody,
                    family: .jetbrains,
                    color: Color(hex: "#94A3B8")
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)

            OnboardingProgressBar(current: 1, total: 3)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

            Button(action: onNext) {
                HStack {
                    Text("siguiente")
                        .textStyle(
                            .monoBody,
                            family: .spaceGrotesk,
                            color: Color(hex: "#0F172A"),
                            uppercase: true
                        )

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#0F172A"))
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.accentYellow)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}

#Preview {
    OnboardingStep1View(onNext: {})
}
