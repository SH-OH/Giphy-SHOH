//
//  SearchType.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/27.
//

import Foundation
import UIKit.UIColor

enum SearchType: Int, CaseIterable {
    case GIFs = 1
    case Stickers
    
    var apiValue: String {
        switch self {
        case .GIFs: return "gifs"
        case .Stickers: return "stickers"
        }
    }
    
    var buttonColor: UIColor {
        switch self {
        case .GIFs: return UIColor.systemIndigo
        case .Stickers: return UIColor.systemTeal
        }
    }
    
    var buttonTitle: String {
        return "\(self)"
    }
    
    var detailTitle: String {
        switch self {
        case .GIFs: return "GIF"
        case .Stickers: return "Sticker"
        }
    }
    
}
