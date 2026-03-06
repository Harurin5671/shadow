//
//  OnboardingProgressBar.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 4/03/26.
//

import Foundation
import SwiftUI

struct OnboardingProgressBar: View {
    let current: Int
    let total: Int

    var progress: Double {
        Double(current) / Double(total)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {

                // Track vacio
                Rectangle()
                    .fill(Color.borderDefault)
                    .frame(height: 2)

                // Progreso lleno
                Rectangle()
                    .fill(Color.accentYellow)
                    .frame(width: geo.size.width * progress, height: 2)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 2)
    }
}

#Preview {
    OnboardingProgressBar(current: 1, total: 3)
}
