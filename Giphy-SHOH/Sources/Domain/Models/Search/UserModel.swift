//
//  UserModel.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/25.
//

import Foundation

struct UserModel: Decodable {
    let avatarUrl: String
    let profileUrl: String
    let username: String
    let displayName: String
    let isVerified: Bool
}
