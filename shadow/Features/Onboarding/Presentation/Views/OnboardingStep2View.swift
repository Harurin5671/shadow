//
//  OnboardingStep2View.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 3/03/26.
//

import SwiftUI

struct OnboardingStep2View: View {
    let onNext: () -> Void
    let onPreview: () -> Void

    var body: some View {
        Text( /*@START_MENU_TOKEN@*/"Hello, World!" /*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    OnboardingStep2View(
        onNext: {},
        onPreview: {}
    )
}
