//
//  SearchViewReactor.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/27.
//

import Foundation
import ReactorKit
import RxRelay

final class SearchViewReactor: Reactor {
    
    enum Action {
        case didTapTypeButton(SearchType)
        case enterKeyword(String?)
        case enterSearchKeyword(String)
    }
    
    enum Mutation {
        case updateSearchType(SearchType)
        case updateCurKeyword(String?)
        case updateSearchKeyword(String)
    }
    
    struct State {
        var searchType: RevisionedData<SearchType>
        var curKeyword: RevisionedData<String?>
        var searchedKeyword: RevisionedData<String>
    }
    
    let initialState: State
    let useCase: GiphyUseCase
    
    let viewControllerIndex: UInt
    let isSearchResult: Bool
    
    let pushControlRelay: PublishRelay<String>
    
    // MARK: - Default First Search VC init
    
    init(_ useCase: GiphyUseCase) {
        self.initialState = .init(
            searchType: .init(data: .GIFs),
            curKeyword: .init(data: nil),
            searchedKeyword: .init(data: "")
        )
        self.useCase = useCase
        
        self.viewControllerIndex = 0
        self.isSearchResult = false
        
        self.pushControlRelay = .init()
    }
    
    // MARK: - Result Search VC init From The Second VC
    
    init(_ reactor: SearchViewReactor) {
        let current = reactor.currentState
        let searchKeyword: String = current.curKeyword.data ?? ""
        let vcIndex: UInt = reactor.viewControllerIndex+1
        self.initialState = .init(
            searchType: .init(vcIndex: vcIndex, data: current.searchType.data),
            curKeyword: .init(vcIndex: vcIndex, data: searchKeyword),
            searchedKeyword: .init(vcIndex: vcIndex, data: searchKeyword)
        )
        self.useCase = reactor.useCase
        
        self.viewControllerIndex = vcIndex
        self.isSearchResult = true
        self.pushControlRelay = .init()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .didTapTypeButton(searchType):
            return .just(Mutation.updateSearchType(searchType))
        case let .enterKeyword(keyword):
            return .just(Mutation.updateCurKeyword(keyword))
        case let .enterSearchKeyword(keyword):
            return .just(Mutation.updateSearchKeyword(keyword))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .updateSearchType(searchType):
            newState.searchType.update(data: searchType)
            return newState
        case let .updateCurKeyword(keyword):
            newState.curKeyword.update(data: keyword)
            return newState
        case let .updateSearchKeyword(keyword):
            newState.searchedKeyword.update(data: keyword)
            return newState
        }
    }
}
