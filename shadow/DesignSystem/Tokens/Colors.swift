//
//  Colors.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 1/03/26.
//

import Foundation
import SwiftUI

extension Color {
    // MARK: Backgrounds
    static let bgPrimaryShadow: Color = Color.bgPrimary
    static let bgSurfaceShadow: Color = Color.bgSurface
    static let bgElevatedShadow: Color = Color.bgElevated
    
    // MARK: Borders
    static let borderDefaultShadow: Color = Color.borderDefault
    static let borderSubtleShadow: Color = Color.borderSubtle
    
    // MARK: Accents
    static let accentYellowShadow: Color = Color.accentYellow
    static let accentCyanShadow: Color = Color.accentCyan
    
    // MARK: Text
    static let textPrimaryShadow: Color = Color.textPrimary
    static let textMutedShadow: Color = Color.textMuted
    static let textDisabledShadow: Color = Color.textDisabled
    
    // MARK: Semantic
    static let dangerShadow = Color.danger
    static let warningShadow = Color.warning
    
    // MARK: Glass Variants
    static var glassWhite08: Color {
        Color.white.opacity(0.08)
    }
    
    static var glassWhite15: Color {
        Color.white.opacity(0.15)
    }
    
    static var glassYellow10: Color {
        Color.accentYellow.opacity(0.10)
    }
    
    static var glassCyan08: Color {
        Color.accentCyan.opacity(0.08)
    }
    
    static var glassRed10: Color {
        Color.danger.opacity(0.10)
    }
}
