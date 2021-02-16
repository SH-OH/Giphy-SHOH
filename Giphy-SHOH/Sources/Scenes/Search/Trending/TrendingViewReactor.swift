//
//  TrendingViewReactor.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/28.
//

import Foundation
import ReactorKit

final class TrendingViewReactor: Reactor {
    enum Action {
        case callGetTrendingSearches
    }
    
    enum Mutation {
        case setTrendingSearches([String])
    }
    
    struct State {
        var trendingSearches: [String]
    }
    
    let initialState: State
    let searchReactor: SearchViewReactor
    private let useCase: GiphyUseCase
    
    init(_ searchReactor: SearchViewReactor) {
        self.initialState = .init(
            trendingSearches: []
        )
        self.searchReactor = searchReactor
        self.useCase = searchReactor.useCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .callGetTrendingSearches:
            let setTrendingSearches: Observable<Mutation> = self.useCase
                .getTrendingSearches()
                .filter { !$0.isEmpty }
                .map({ (searches) -> [String] in
                    var searches = searches
                    searches.insert("Trending Searches", at: 0)
                    return searches
                })
                .map { Mutation.setTrendingSearches($0)}
            
            return setTrendingSearches
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setTrendingSearches(trendingSearches):
            newState.trendingSearches = trendingSearches
            return newState
        }
    }
}
