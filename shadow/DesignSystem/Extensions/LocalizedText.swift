//
//  LocalizedText.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 4/03/26.
//

import Foundation
import SwiftUI

extension Text {
    static func localized(_ key: String.LocalizationValue) -> Text {
        Text(String(localized: key).replacingOccurrences(of: "\\n", with: "\n"))
    }
}

extension String {
    var localized: String {
        String(localized: String.LocalizationValue(self))
            .replacingOccurrences(of: "\\n", with: "\n")
    }
}
