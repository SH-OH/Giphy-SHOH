//
//  UserDefaultsManager.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/02/03.
//

import Foundation
import RxSwift

enum UserDefaultsType {
    case Favorites(_ id: String? = nil)
    
    var key: String {
        switch self {
        case .Favorites:
            return "Favorites"
        }
    }
}

struct UserDefaultsManager {
    @discardableResult
    static func update(_ type: UserDefaultsType,
                       completion: SimpleCompletion? = nil) -> Bool? {
        switch type {
        case let .Favorites(id):
            guard let id = id else { return nil }
            var list = UserDefaultsManager.getStringArray(type)
            let isEmpty = !list.contains(id)
            if isEmpty {
                list.insert(id, at: 0)
            } else {
                if let index = list.firstIndex(where: { $0 == id }) {
                    list.remove(at: index)
                }
            }
            UserDefaultsManager.set(
                type,
                value: list,
                completion: completion
            )
            return isEmpty
        }
    }
}

extension UserDefaultsManager {
    static func getStringArray(_ type: UserDefaultsType) -> [String] {
        return UserDefaults.standard.stringArray(forKey: type.key) ?? []
    }
    
    static func set(_ key: UserDefaultsType,
                    value: Any,
                    completion: SimpleCompletion? = nil) {
        UserDefaults.standard.set(value, forKey: key.key)
        completion?()
    }
    
    static func remove(_ key: UserDefaultsType) {
        UserDefaults.standard.removeObject(forKey: key.key)
    }
}
