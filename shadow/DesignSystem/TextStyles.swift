//
//  TextStyles.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 3/03/26.
//

import Foundation
import SwiftUI

enum TextStyleType {
    case displayHero
    case displayLarge
    case displayMedium
    case displaySmall
    case labelLarge
    case labelMedium
    case labelSmall
    case monoBody
    case monoSmall
    case monoCaption
    case monoMicro
}

extension TextStyleType {
    var isLabel: Bool {
        switch self {
        case .labelLarge, .labelMedium, .labelSmall:
            return true
        default:
            return false
        }
    }
}

struct AppTextStyle: ViewModifier {

    let type: TextStyleType
    let family: AppFontFamily
    let color: Color
    let forceUppercase: Bool?
    let fontSize: CGFloat?

    init(
        _ type: TextStyleType,
        family: AppFontFamily = .syne,
        color: Color = .primary,
        uppercase: Bool? = nil,
        size: CGFloat? = nil
    ) {
        self.type = type
        self.family = family
        self.color = color
        self.forceUppercase = uppercase
        self.fontSize = size
    }

    func body(content: Content) -> some View {
        content
            .font(resolvedFont)
            .tracking(trackingValue)
            .foregroundStyle(color)
            .textCase(resolvedUppercase ? .uppercase : nil)
    }

    private var resolvedFont: Font {
        // Si se pasa un fontSize override, se llama a AppTypography con ese tamaño directamente
        AppTypography.font(for: type, family: family, sizeOverride: fontSize)
    }

    private var resolvedUppercase: Bool {
        if let forceUppercase {
            return forceUppercase
        }
        return type.isLabel
    }

    private var trackingValue: CGFloat {
        switch type {
        case .displayHero: return -1
        case .displayLarge, .displayMedium: return -0.5
        case .labelLarge: return 1
        default: return 0
        }
    }
}

extension View {
    func textStyle(
        _ type: TextStyleType,
        family: AppFontFamily = .syne,
        color: Color = .primary,
        uppercase: Bool? = nil,
        size: CGFloat? = nil
    ) -> some View {
        self.modifier(AppTextStyle(
            type,
            family: family,
            color: color,
            uppercase: uppercase,
            size: size
        ))
    }
}
