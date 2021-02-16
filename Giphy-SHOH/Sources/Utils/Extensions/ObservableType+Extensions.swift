//
//  ObservableType+Extensions.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/28.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
    func asDriverOnEmpty() -> Driver<Element> {
        return asDriver(onErrorDriveWith: .empty())
    }
}
