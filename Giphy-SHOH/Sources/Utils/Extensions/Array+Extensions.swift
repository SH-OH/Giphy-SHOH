//
//  Array+Extensions.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/25.
//

import Foundation

extension Array {
    public subscript(safe index: Int) -> Element? {
        guard index >= 0 else { return nil }
        return index < count ? self[index] : nil
    }
}

extension Array where Element: Equatable {
    static func == (
        lhs: Array<Element>,
        rhs: Array<Element>
    ) -> Bool {
        if lhs.count != rhs.count { return false }
        return zip(lhs, rhs).contains { $0 == $1 }
    }
}
