//
//  GiphyService.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/25.
//

import Foundation
import Moya

enum GiphyService {
    case search(
            type: SearchType,
            query: String,
            limit: Int,
            offset: Int
         )
    case searchById(
            id: String
         )
    case searchByIds(
            ids: String
         )
    case autocomplete(
            query: String,
            limit: Int,
            offset: Int
         )
    case trendingSearches
    case suggestions(
            term: String
         )
}

extension GiphyService: TargetType {
    var baseURL: URL {
        return URL(string: API.giphy.baseUrl)!
    }
    
    var path: String {
        switch self {
        case let .search(type, _, _, _):
            return "/v1/\(type.apiValue)/search"
        case let .searchById(id):
            return "/v1/gifs/\(id)"
        case .searchByIds:
            return "/v1/gifs"
        case .autocomplete:
            return "/v1/gifs/search/tags"
        case let .suggestions(term):
            return "/v1/tags/related/\(term)"
        case .trendingSearches:
            return "/v1/trending/searches"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .search,
             .searchById,
             .searchByIds,
             .autocomplete,
             .suggestions,
             .trendingSearches:
            return .get
        }
    }
    
    var sampleData: Data {
        return .init()
    }
    
    var task: Task {
        var params: [String: Any] = [:]
        params["api_key"] = API.GIPHY_APIKEY
        switch self {
        case let .search(_, query, limit, offset),
             let .autocomplete(query, limit, offset):
            params["q"] = query
            params["limit"] = limit
            params["offset"] = offset
        case let .searchByIds(ids):
            params["ids"] = ids
        case .searchById,
             .suggestions,
             .trendingSearches:
            break
        }
        return .requestParameters(parameters: params,
                                  encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        return nil
    }
}
