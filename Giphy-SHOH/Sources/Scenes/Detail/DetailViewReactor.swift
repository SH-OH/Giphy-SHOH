//
//  DetailViewReactor.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/02/01.
//

import Foundation
import ReactorKit
import UIKit

final class DetailViewReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var searchDataInDetail: [SearchData]
    }
    
    let initialState: State
    let selectIndex: Int
    
    var sizeCache: [String: CGSize]
    
    init(searchData: [SearchData],
        selectIndex: Int) {
        self.initialState = .init(
            searchDataInDetail: searchData
        )
        self.selectIndex = selectIndex
        
        self.sizeCache = [:]
    }
    
}
