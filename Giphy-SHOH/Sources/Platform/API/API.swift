//
//  API.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/25.
//

import Foundation

enum API {
    case giphy
    
    var baseUrl: String {
        switch self {
        case .giphy:
            return "https://api.giphy.com"
        }
    }
    
    static let GIPHY_APIKEY: String = "C7P59m18vbOEd7fP9TT1T2xmK3mmspL6"
}
