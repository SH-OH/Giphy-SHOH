//
//  FavoritesViewReactor.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/27.
//

import Foundation
import ReactorKit
import RxRelay

final class FavoritesViewReactor: Reactor {
    enum Action {
        case callGetSearchByIds(_ ids: [String])
        case getUDFavoritesIds([String])
    }
    
    enum Mutation {
        case setFavorites([String])
        case setFavoritesData([SearchData])
        case updateFavoritesValue(SearchData, Bool)
    }
    
    struct State {
        var favorites: [String]?
        var favoritesData: [SearchData]
        
    }
    
    let initialState: State
    let useCase: GiphyUseCase
    
    init(_ useCase: GiphyUseCase) {
        self.initialState = .init(
            favoritesData: []
        )
        self.useCase = useCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .callGetSearchByIds(ids):
            guard !ids.isEmpty else {
                return .just(Mutation.setFavoritesData([]))
            }
            
            let updateFavoritesData: Observable<Mutation> = self.useCase
                .getSearchByIds(ids)
                .map { Mutation.setFavoritesData($0) }
            
            return updateFavoritesData
        case let .getUDFavoritesIds(updateIds):
            guard let currentIds = currentState.favorites else {
                return .just(Mutation.setFavorites(updateIds))
            }
            
            let isAdd: Bool = updateIds.count > currentIds.count
            
            let addData: Observable<Mutation> = self.useCase
                .getSearchById(updateIds.first)
                .map { Mutation.updateFavoritesValue($0, true) }

            let removeData: Observable<Mutation> = Observable.just(Set(currentIds))
                .filter { !$0.isEmpty }
                .flatMapLatest({ [weak self] (currentIdsSet) -> Observable<SearchData> in
                    guard let self = self else { return .empty() }
                    let currentIdsSet = Set(currentIds)
                    let subtract = currentIdsSet.subtracting(Set(updateIds))
                    if let removeId = subtract.first {
                        let currentData = self.currentState.favoritesData
                        if let removeData = currentData.first(where: { $0.id == removeId }) {
                            return .just(removeData)
                        }
                    }
                    return .empty()
                })
                .map { Mutation.updateFavoritesValue($0, false)}
            
            let update: Observable<Mutation> = isAdd
                ? addData
                : removeData
            
            return update
                .concat(Observable.just(Mutation.setFavorites(updateIds)))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setFavorites(favorites):
            newState.favorites = favorites
            return newState
        case let .setFavoritesData(favoritesData):
            newState.favoritesData = favoritesData
            return newState
        case let .updateFavoritesValue(updateData, isAdd):
            if isAdd {
                newState.favoritesData.insert(updateData, at: 0)
            } else {
                if let index = newState.favoritesData.firstIndex(of: updateData) {
                    newState.favoritesData.remove(at: index)
                }
            }
            return newState
        }
    }
}
