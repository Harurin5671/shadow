//
//  DotGridBackground.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 4/03/26.
//

import Foundation
import SwiftUI

struct DotGridBackground: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 40
            let dotSize: CGFloat = 1.5

            var x: CGFloat = spacing / 2
            while x < size.width {
                var y: CGFloat = spacing / 2
                while y < size.height {
                    context.fill(
                        Path(
                            ellipseIn: CGRect(
                                x: x - dotSize / 2,
                                y: y - dotSize / 2,
                                width: dotSize,
                                height: dotSize
                            )
                        ),
                        with: .color(Color.accentYellow)
                    )
                    y += spacing
                }
                x += spacing
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

#Preview {
    DotGridBackground()
}
