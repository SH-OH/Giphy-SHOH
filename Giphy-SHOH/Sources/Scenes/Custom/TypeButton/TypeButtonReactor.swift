//
//  TypeButtonReactor.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/30.
//

import Foundation
import ReactorKit
import UIKit.UIColor

final class TypeButtonReactor: Reactor {
    
    typealias Action = NoAction
    
    struct State {
        let title: String
        let color: UIColor
    }
    
    let initialState: State
    
    init(title: String,
         color: UIColor) {
        self.initialState = .init(
            title: title,
            color: color
        )
    }
    
}
