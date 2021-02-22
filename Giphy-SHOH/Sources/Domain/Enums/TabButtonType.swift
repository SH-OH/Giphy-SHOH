//
//  TabButtonType.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/26.
//

import Foundation
import ReactorKit

enum TabButtonType: Int, CaseIterable {
    case Search = 1
    case Favorites
    
    var scrollIndex: Int {
        return self.rawValue-1
    }
    
    func navigation(_ navigationControllers: [BaseNavigationController]) -> BaseNavigationController {
        return navigationControllers[self.scrollIndex]
    }
    
}
