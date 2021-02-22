//
//  MainTabViewReactor.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/25.
//

import Foundation
import ReactorKit

final class MainTabViewReactor: Reactor {
    
    enum Action {
        case didTapTabButton(TabButtonType)
    }
    
    struct State {
        var prevTabButton: TabButtonType
        var curTabButton: TabButtonType
    }
    
    let initialState: State
    
    init() {
        self.initialState = .init(
            prevTabButton: .Search,
            curTabButton: .Search
        )
    }
    
    func mutate(action: Action) -> Observable<Action> {
        switch action {
        case let .didTapTabButton(type):
            return .just(Mutation.didTapTabButton(type))
        }
    }
    
    func reduce(state: State, mutation: Action) -> State {
        var newState = state
        switch mutation {
        case let .didTapTabButton(type):
            newState.prevTabButton = newState.curTabButton
            newState.curTabButton = type
            return newState
        }
    }
    
}
