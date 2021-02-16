//
//  GiphyUseCase.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/25.
//

import Foundation
import RxSwift

struct GiphyUseCase: GiphyProtocol {
    
    enum Constants {
        static let SearchLimit: Int = 30
        static let AutoCompleteLimit: Int = 5
    }
    
    var provider: BaseProvider<GiphyService>
    
    init(_ provider: BaseProvider<GiphyService>) {
        self.provider = provider
    }
    
    func getSearch(
        _ type: SearchType,
        query: String,
        offset: Int
    ) -> Observable<[SearchData]> {
        let limit: Int = Constants.SearchLimit
        return self.provider.request(
            [SearchData].self,
            target: .search(
                type: type,
                query: query,
                limit: limit,
                offset: offset
            )
        ).asObservable()
        .map { $0.data }
    }
    
    func getSearchById(_ id: String?) -> Observable<SearchData> {
        guard let id = id else { return .empty() }
        return self.provider.request(
            SearchData.self,
            target: .searchById(id: id)
        ).asObservable()
        .compactMap { $0.data }
    }
    
    
    func getSearchByIds(_ ids: [String]) -> Observable<[SearchData]> {
        let separatedIds = ids.joined(separator: ", ")
        return self.provider.request(
            [SearchData].self,
            target: .searchByIds(ids: separatedIds)
        ).asObservable()
        .map { $0.data }
    }
    
    func getAutoComplete(_ query: String) -> Observable<[TermData]> {
        let limit: Int = Constants.AutoCompleteLimit
        let offset: Int = 0
        return self.provider.request(
            [TermData].self,
            target: .autocomplete(
                query: query,
                limit: limit,
                offset: offset
            )
        ).asObservable()
        .map { $0.data }
    }
    
    func getSuggestions(_ term: String) -> Observable<[TermData]> {
        return self.provider.request(
            [TermData].self,
            target: .suggestions(term: term)
        ).asObservable()
        .map { $0.data }
    }
    
    func getTrendingSearches() -> Observable<[String]> {
        return self.provider.request(
            [String].self,
            target: .trendingSearches
        ).asObservable()
        .map { $0.data }
    }
}
