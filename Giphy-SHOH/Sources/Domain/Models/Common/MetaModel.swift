//
//  MetaModel.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/27.
//

import Foundation

struct MetaModel: Decodable {
    let status: Int
    let msg: String
    let responseId: String
}
