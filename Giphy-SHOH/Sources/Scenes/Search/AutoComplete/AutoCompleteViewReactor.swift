//
//  AutoCompleteViewReactor.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/27.
//

import Foundation
import ReactorKit
import RxCocoa

final class AutoCompleteViewReactor: Reactor {
    enum Action {
        case getSearchKeywordForAutoComplete(String)
    }
    
    enum Mutation {
        case updateAutoCompleteData([TermData])
    }
    struct State {
        var autoCompleteData: [TermData]
        
        var curKeyword: String?
    }
    
    let initialState: State
    let searchReactor: SearchViewReactor
    let useCase: GiphyUseCase
    
    init(_ searchReactor: SearchViewReactor,
         useCase: GiphyUseCase,
         curKeyword: String?) {
        self.initialState = .init(
            autoCompleteData: [],
            curKeyword: curKeyword
        )
        self.searchReactor = searchReactor
        self.useCase = useCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .getSearchKeywordForAutoComplete(keyword):
            let updateAutoCompleteData: Observable<Mutation> = self.useCase
                .getAutoComplete(keyword)
                .map { Mutation.updateAutoCompleteData($0) }
            
            return updateAutoCompleteData
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .updateAutoCompleteData(autoCompleteData):
            newState.autoCompleteData = autoCompleteData
            return newState
        }
    }
}
