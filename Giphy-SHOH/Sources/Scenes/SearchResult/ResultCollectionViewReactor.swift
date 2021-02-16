//
//  ResultCollectionViewReactor.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/30.
//

import Foundation
import ReactorKit
import UIKit

final class ResultCollectionViewReactor: Reactor {
    enum APICallType {
        case initialize, pagination
    }
    
    enum Action {
        case getSearchKeywordForResultCV(String)
        case didSelectSearchType(SearchType)
        case callGetSearch(
                _ query: String,
                searchType: SearchType,
                apiCallType: APICallType
             )
    }
    enum Mutation {
        case updateSearchKeywordForResultCV(String)
        case updateSearchType(SearchType)
        case updateSearchData(([SearchData], APICallType))
    }
    
    struct State {
        var searchData: [SearchData]
        var searchType: SearchType
        
        var searchKeyword: String
        
        var apiCallType: APICallType?
    }
    
    let initialState: State
    let searchReactor: SearchViewReactor
    let useCase: GiphyUseCase
    
    var sizeCache: [String: CGSize]
    
    init(_ searchReactor: SearchViewReactor) {
        let searchType = searchReactor.currentState.searchType.data
        self.initialState = .init(
            searchData: [],
            searchType: searchType,
            searchKeyword: ""
        )
        self.useCase = searchReactor.useCase
        self.searchReactor = searchReactor
        self.sizeCache = [:]
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .callGetSearch(query, searchType, apiCallType):
            let offset: Int = apiCallType == .initialize
                ? 0
                : currentState.searchData.count
            let updateSearchData: Observable<Mutation> = self.useCase
                .getSearch(
                    searchType,
                    query: query,
                    offset: offset
                )
                .map { Mutation.updateSearchData(($0, apiCallType)) }
            
            return updateSearchData
        case let .getSearchKeywordForResultCV(keyword):
            return .just(Mutation.updateSearchKeywordForResultCV(keyword))
        case let .didSelectSearchType(searchType):
            return .just(Mutation.updateSearchType(searchType))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .updateSearchData((searchData, apiCallType)):
            newState.apiCallType = apiCallType
            if apiCallType == .pagination {
                newState.searchData.append(contentsOf: searchData)
            } else {
                newState.searchData = searchData
            }
            return newState
        case let .updateSearchKeywordForResultCV(keyword):
            newState.searchKeyword = keyword
            return newState
        case let .updateSearchType(searchType):
            newState.searchType = searchType
            return newState
        }
    }
}

// MARK: - For Filter

extension ResultCollectionViewReactor {
    func prefetchingCount() -> Int {
        return currentState.searchData.count-15
    }
}
