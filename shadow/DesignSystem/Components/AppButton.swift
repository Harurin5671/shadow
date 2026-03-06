//
//  AppButton.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 6/03/26.
//

import SwiftUI

enum AppButtonLayout {
    case center
    case spaceBetween
    case leading
    case trailing
}

struct AppButton: View {
    let label: LocalizedStringKey
    let action: () -> Void

    var layout: AppButtonLayout = .spaceBetween
    var leadingIcon: String? = nil
    var trailingIcon: String? = nil
    var foregroundColor: Color = Color(hex: "#0F172A")
    var backgroundColor: Color = Color.accentYellow
    var height: CGFloat = 56
    var horizontalPadding: CGFloat = 24
    var cornerRadius: CGFloat = 0
    var uppercase: Bool = true
    var iconSize: CGFloat = 20
    
    // Texto
    var textStyle: TextStyleType = .labelLarge
    var fontFamily: AppFontFamily = .spaceGrotesk
    var fontSize: CGFloat? = nil
    
    // Border
    var borderColor: Color = .clear
    var borderWidth: CGFloat = 0

    var body: some View {
        Button(action: action) {
            Group {
                switch layout {
                case .spaceBetween:
                    HStack {
                        leadingIconView
                        Text(label)
                            .textStyle(
                                textStyle,
                                family: fontFamily,
                                color: .color(foregroundColor),
                                uppercase: uppercase,
                                size: fontSize
                            )
                        Spacer()
                        trailingIconView
                    }

                case .center:
                    HStack(spacing: 8) {
                        leadingIconView
                        Text(label)
                            .textStyle(
                                textStyle,
                                family: fontFamily,
                                color: .color(foregroundColor),
                                uppercase: uppercase,
                                size: fontSize
                            )
                        trailingIconView
                    }
                    .frame(maxWidth: .infinity)

                case .leading:
                    HStack(spacing: 8) {
                        leadingIconView
                        Text(label)
                            .textStyle(
                                textStyle,
                                family: fontFamily,
                                color: .color(foregroundColor),
                                uppercase: uppercase,
                                size: fontSize
                            )
                        trailingIconView
                        Spacer()
                    }

                case .trailing:
                    HStack(spacing: 8) {
                        Spacer()
                        leadingIconView
                        Text(label)
                            .textStyle(
                                textStyle,
                                family: fontFamily,
                                color: .color(foregroundColor),
                                uppercase: uppercase,
                                size: fontSize
                            )
                        trailingIconView
                    }
                }
            }
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            }
        }
    }

    @ViewBuilder
    private var leadingIconView: some View {
        if let icon = leadingIcon {
            Image(systemName: icon)
                .font(.system(size: iconSize))
                .foregroundStyle(foregroundColor)
        }
    }

    @ViewBuilder
    private var trailingIconView: some View {
        if let icon = trailingIcon {
            Image(systemName: icon)
                .font(.system(size: iconSize))
                .foregroundStyle(foregroundColor)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        // Default
        AppButton(label: "Siguiente", action: {})
        
        // Center
        AppButton(label: "Aceptar", action: {}, layout: .center)
        
        // Con iconos
        AppButton(label: "Continuar", action: {}, trailingIcon: "arrow.right")
        
        // Colores custom
        AppButton(label: "Peligro", action: {}, foregroundColor: .white, backgroundColor: .red, cornerRadius: 12)
        
        AppButton(
                    label: "Unirse con código",
                    action: {},
                    layout: .center,
                    leadingIcon: "qrcode",
                    foregroundColor: .white,
                    backgroundColor: .clear,
                    borderColor: Color.white.opacity(0.2),
                    borderWidth: 1
                )
        
        AppButton(
                    label: "Custom font",
                    action: {},
                    layout: .center,
                    textStyle: .monoBody,
                    fontFamily: .jetbrains,
                    fontSize: 12
                )
    }
    .padding()
    .background(Color.bgPrimary)
}
