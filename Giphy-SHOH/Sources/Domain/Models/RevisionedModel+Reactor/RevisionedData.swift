//
//  RevisionedData.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/30.
//

import Foundation

struct RevisionedData<T> {
    
    private var revision: UInt
    private var vcIndex: UInt
    
    var data: T
    
    init(
        revision: UInt = 0,
        vcIndex: UInt = 0,
        data: T
    ) {
        self.revision = revision
        self.vcIndex = vcIndex
        self.data = data
    }
}

extension RevisionedData: Equatable {
    static func == (
        lhs: RevisionedData,
        rhs: RevisionedData
    ) -> Bool {
        return lhs.revision == rhs.revision
            &&
            lhs.vcIndex == rhs.vcIndex
    }
}

extension RevisionedData {
    mutating func update(data: T) {
        self.revision = self.revision+1
        self.data = data
    }
    func isCurrentVCIndex(_ currentVCIndex: Int) -> Bool {
        return self.vcIndex
            ==
            currentVCIndex
    }
    func getRevision() -> UInt {
        return self.revision
    }
}
