//
//  Typography.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 3/03/26.
//

import Foundation
import SwiftUI

enum AppFontFamily {
    case syne
    case jetbrains
    case spaceGrotesk
}

struct AppTypography {

    static func font(
        for type: TextStyleType,
        family: AppFontFamily,
        sizeOverride: CGFloat? = nil
    ) -> Font {

        let size: CGFloat = sizeOverride ?? defaultSize(for: type)

        return Font.custom(fontName(for: type, family: family), size: size)
    }

    private static func defaultSize(for type: TextStyleType) -> CGFloat {
        switch type {
        case .displayHero:   return 11
        case .displayLarge:  return 32
        case .displayMedium: return 24
        case .displaySmall:  return 18
        case .labelLarge:    return 14
        case .labelMedium:   return 11
        case .labelSmall:    return 10
        case .monoBody:      return 14
        case .monoSmall:     return 13
        case .monoCaption:   return 11
        case .monoMicro:     return 10
        }
    }

    private static func fontName(
        for type: TextStyleType,
        family: AppFontFamily
    ) -> String {

        switch type {

        case .monoBody, .monoSmall:
            return "JetBrainsMono-Regular"

        case .monoCaption, .monoMicro:
            return "JetBrainsMono-Light"

        default:
            switch family {
            case .syne:
                return type.isLabel
                    ? "Syne-Bold"
                    : "Syne-ExtraBold"

            case .spaceGrotesk:
                return "SpaceGrotesk-Bold"

            case .jetbrains:
                return "JetBrainsMono-Regular"
            }
        }
    }
}
