//
//  RoomCreationTopBar.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 7/03/26.
//

import SwiftUI

struct TopBarAction {
    let content: AnyView
    
    // Texto
    static func text(_ value: String, style: TextStyleType = .monoMicro, family: AppFontFamily = .jetbrainsRegular, color: Color = Color.textMuted) -> TopBarAction {
        TopBarAction(content: AnyView(
            Text(value)
                .textStyle(style, family: family, color: .color(color))
        ))
    }
    
    // Icono con acción
    static func icon(_ systemName: String, color: Color = Color.textPrimary, action: @escaping () -> Void) -> TopBarAction {
        TopBarAction(content: AnyView(
            Button(action: action) {
                Image(systemName: systemName)
                    .foregroundStyle(color)
            }
        ))
    }
    
    // Cualquier View custom
    static func custom<V: View>(_ view: V) -> TopBarAction {
        TopBarAction(content: AnyView(view))
    }
}

struct RoomCreationTopBar: View {
    
    var title: String? = nil
    var onBack: (() -> Void)? = nil
    var trailing: [TopBarAction] = []
    
    var body: some View {
        HStack(spacing: 12) {
            
            // Leading — back o espacio vacío para centrar
            Group {
                if let onBack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.textPrimary)
                    }
                } else {
                    Color.clear
                }
            }
            .frame(width: 24)
            
            Spacer()
            
            // Título central
            if let title {
                Text(title)
                    .textStyle(.labelMedium, family: .syneBold)
                    .foregroundStyle(Color.textMuted)
            }
            
            Spacer()
            
            // Trailing actions
            HStack(spacing: 12) {
                ForEach(0..<trailing.count, id: \.self) { i in
                    trailing[i].content
                }
            }
            .frame(minWidth: 24, alignment: .trailing)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 32)
    }
}

#Preview {
    RoomCreationTopBar()
}
