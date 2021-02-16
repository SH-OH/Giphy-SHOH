//
//  KeyedDecodingContainer+Extensions.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/26.
//

import Foundation

extension KeyedDecodingContainer {
    func decode(_ type: [ImageType: ImageModel].Type,
                forKey key: Key) throws -> [ImageType: ImageModel] {
        let imageDic = try self.decode([String: ImageModel].self, forKey: key)
        var result: [ImageType: ImageModel] = [:]
        for (key, value) in imageDic {
            if let type = ImageType(rawValue: key) {
                result.updateValue(value, forKey: type)
            }
        }
        return result
    }
}
