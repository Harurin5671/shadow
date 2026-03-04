//
//  StackedCardIcon.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 4/03/26.
//

import Foundation
import SwiftUI

enum CardIconSource {
    case system(String)
    case asset(String)
    case custom(Image)
}

struct StackedCardIcon: View {

    let icon: CardIconSource
    let backRotation: Double
    let midRotation: Double
    let cardSize: CGFloat
    let iconSize: CGFloat
    let accentColor: Color

    init(
        icon: CardIconSource = .system("lock.fill"),
        backRotation: Double = -12,
        midRotation: Double = 6,
        cardSize: CGFloat = 192,
        iconSize: CGFloat = 48,
        accentColor: Color = Color(hex: "#E7FF47")
    ) {
        self.icon = icon
        self.backRotation = backRotation
        self.midRotation = midRotation
        self.cardSize = cardSize
        self.iconSize = iconSize
        self.accentColor = accentColor
    }

    var body: some View {
        ZStack(alignment: .center) {
            // Atrás
            cardLayer(size: cardSize, rotation: backRotation, opacity: 0.6)

            // Medio
            cardLayer(size: cardSize, rotation: midRotation, opacity: 0.6)

            // Frontal
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "#21230F").opacity(0.50))
                .frame(width: cardSize * 0.833, height: cardSize * 0.833)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(accentColor, lineWidth: 2)
                )

            // Ícono
            resolvedIcon
                .foregroundColor(accentColor)
        }
    }

    // MARK: - Private

    private func cardLayer(size: CGFloat, rotation: Double, opacity: Double) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(accentColor.opacity(0.05))
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(accentColor.opacity(opacity), lineWidth: 1)
            )
            .rotationEffect(.degrees(rotation))
    }

    @ViewBuilder
    private var resolvedIcon: some View {
        switch icon {
        case .system(let name):
            Image(systemName: name)
                .font(.system(size: iconSize))
        case .asset(let name):
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
        case .custom(let image):
            image
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
        }
    }
}
