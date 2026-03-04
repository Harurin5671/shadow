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

// MARK: - TextColor Token

enum TextColor {
    case fixed(Color)
    case primary
    case secondary
    case tertiary
    case style(AnyShapeStyle)

    // Colores directos
    static func color(_ color: Color) -> TextColor { .fixed(color) }

    // Gradientes
    static func linear(_ gradient: LinearGradient) -> TextColor {
        .style(AnyShapeStyle(gradient))
    }
    static func radial(_ gradient: RadialGradient) -> TextColor {
        .style(AnyShapeStyle(gradient))
    }
    static func angular(_ gradient: AngularGradient) -> TextColor {
        .style(AnyShapeStyle(gradient))
    }

    // Cualquier ShapeStyle custom
    static func any<S: ShapeStyle>(_ style: S) -> TextColor {
        .style(AnyShapeStyle(style))
    }

    var shapeStyle: AnyShapeStyle {
        switch self {
        case .fixed(let c):    return AnyShapeStyle(c)
        case .primary:         return AnyShapeStyle(.primary)
        case .secondary:       return AnyShapeStyle(.secondary)
        case .tertiary:        return AnyShapeStyle(.tertiary)
        case .style(let s):    return s
        }
    }
}

// MARK: - TextAlign Token

enum TextAlign {
    case leading, center, trailing

    var alignment: TextAlignment {
        switch self {
        case .leading:   return .leading
        case .center:    return .center
        case .trailing:  return .trailing
        }
    }
}

// MARK: - AppTextStyle

struct AppTextStyle: ViewModifier {

    let type: TextStyleType
    let family: AppFontFamily
    let textColor: TextColor
    let forceUppercase: Bool?
    let fontSize: CGFloat?
    let lineLimit: Int?
    let lineSpacing: CGFloat?
    let alignment: TextAlign?
    let kerning: CGFloat?
    let truncationMode: Text.TruncationMode?

    init(
        _ type: TextStyleType,
        family: AppFontFamily = .syne,
        color: TextColor = .primary,
        uppercase: Bool? = nil,
        size: CGFloat? = nil,
        lineLimit: Int? = nil,
        lineSpacing: CGFloat? = nil,
        alignment: TextAlign? = nil,
        kerning: CGFloat? = nil,
        truncationMode: Text.TruncationMode? = nil
    ) {
        self.type = type
        self.family = family
        self.textColor = color
        self.forceUppercase = uppercase
        self.fontSize = size
        self.lineLimit = lineLimit
        self.lineSpacing = lineSpacing
        self.alignment = alignment
        self.kerning = kerning
        self.truncationMode = truncationMode
    }

    func body(content: Content) -> some View {
        content
            .font(resolvedFont)
            .tracking(kerning ?? defaultTracking)
            .foregroundStyle(textColor.shapeStyle)
            .textCase(resolvedUppercase ? .uppercase : nil)
            .lineLimit(lineLimit)
            .lineSpacing(lineSpacing ?? 0)
            .multilineTextAlignment(alignment?.alignment ?? .leading)
            .truncationMode(truncationMode ?? .tail)
    }

    private var resolvedFont: Font {
        AppTypography.font(for: type, family: family, sizeOverride: fontSize)
    }

    private var resolvedUppercase: Bool {
        forceUppercase ?? type.isLabel
    }

    private var defaultTracking: CGFloat {
        switch type {
        case .displayHero:                  return -1
        case .displayLarge, .displayMedium: return -0.5
        case .labelLarge:                   return 1
        default:                            return 0
        }
    }
}

// MARK: - View Extension

extension View {
    func textStyle(
        _ type: TextStyleType,
        family: AppFontFamily = .syne,
        color: TextColor = .primary,
        uppercase: Bool? = nil,
        size: CGFloat? = nil,
        lineLimit: Int? = nil,
        lineSpacing: CGFloat? = nil,
        alignment: TextAlign? = nil,
        kerning: CGFloat? = nil,
        truncationMode: Text.TruncationMode? = nil
    ) -> some View {
        self.modifier(AppTextStyle(
            type,
            family: family,
            color: color,
            uppercase: uppercase,
            size: size,
            lineLimit: lineLimit,
            lineSpacing: lineSpacing,
            alignment: alignment,
            kerning: kerning,
            truncationMode: truncationMode
        ))
    }
}
