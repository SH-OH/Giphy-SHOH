//
//  Codable+Extensions.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/25.
//

import Foundation

extension Encodable {
    func encode(_ encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        return try encoder.encode(self)
    }
}

extension Decodable {
    static func decode(_ decoder: JSONDecoder = JSONDecoder(),
                       data: Data) throws -> Self {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(self, from: data)
    }
}
