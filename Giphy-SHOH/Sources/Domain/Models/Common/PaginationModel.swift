//
//  PaginationModel.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/27.
//

import Foundation

struct PaginationModel: Decodable {
    let totalCount: Int?
    let count: Int
    let offset: Int
}
