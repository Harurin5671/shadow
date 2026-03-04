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
    case syneBold
    case jetbrains
    case jetbrainsLight
    case spaceGrotesk
    case spaceGroteskRegular
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
        case .displayHero:   return 40
        case .displayLarge:  return 32
        case .displayMedium: return 24
        case .displaySmall:  return 20
        case .labelLarge:    return 16
        case .labelMedium:   return 14
        case .labelSmall:    return 12
        case .monoBody:      return 14
        case .monoSmall:     return 13
        case .monoCaption:   return 12
        case .monoMicro:     return 11
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
            case .syneBold:
                return "Syne-Bold"
                
            case .jetbrainsLight:
                return "JetBrainsMono-Light"

            case .spaceGrotesk:
                return "SpaceGrotesk-Bold"
            case .spaceGroteskRegular:
                return "SpaceGrotesk-Regular"

            case .jetbrains:
                return "JetBrainsMono-Regular"
            }
        }
    }
}
