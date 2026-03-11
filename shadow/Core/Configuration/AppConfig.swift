//
//  AppConfig.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 11/03/26.
//

import Foundation

enum AppConfig {
    static var apiBaseURL: String {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
              !url.isEmpty else {
            fatalError("API_BASE_URL no configurado en Info.plist")
        }
        return url
    }
}
