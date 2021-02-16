//
//  GiphyRootModel.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/25.
//

import Foundation

struct GiphyRootModel<T: Decodable>: Decodable {
    let data: T
    let pagination: PaginationModel?
    let meta: MetaModel
}

struct SearchData: Decodable {
    let type: String
    let id: String
    let url: String
    let username: String
    let title: String
    let rating: RatingType
    var isStickerBoolValue: Bool {
        return isSticker == 1
    }
    let images: [ImageType: ImageModel]
    let user: UserModel?
    
    private let isSticker: Int
}

extension SearchData: Equatable {
    static func == (
        lhs: SearchData,
        rhs: SearchData
    ) -> Bool {
        return lhs.id == rhs.id
    }
}

extension SearchData: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
