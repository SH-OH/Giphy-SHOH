//
//  ColorType.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/30.
//

import Foundation
import UIKit.UIColor

enum ColorType: Int {
    case Indigo
    case Red
    case Blue
    case Pink
    case Teal
    case Gray
    case Green
    case Orange
    case Yellow
    case Purple
    
    init?(_ index: Int) {
        self.init(rawValue: index % 10)
    }
    
    var color: UIColor {
        switch self {
        case .Blue: return .systemBlue
        case .Gray: return .systemGray
        case .Green: return .systemGreen
        case .Indigo: return .systemIndigo
        case .Orange: return .systemOrange
        case .Pink: return .systemPink
        case .Purple: return .systemPurple
        case .Red: return .systemRed
        case .Teal: return .systemTeal
        case .Yellow: return .systemYellow
        }
    }
}
