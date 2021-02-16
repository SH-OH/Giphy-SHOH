//
//  Reactive+Extensions.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/27.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

extension Reactive where Base: UIBarButtonItem {
    var updateBackButton: Binder<BaseViewController> {
        return Binder(base) { barBtn, vc in
            barBtn.target = vc
            barBtn.action = #selector(vc.actionBackButton)
            vc.navigationItem.leftBarButtonItem = barBtn
        }
    }
}

extension Reactive where Base: BaseNavigationController {
    var hiddenBarButton: Binder<Bool> {
        return Binder(base) { nc, isHidden in
            nc.hiddenBarButton(isHidden)
        }
    }
}

extension Reactive where Base: UICollectionView {
    var backgroundIsHidden: Binder<Bool> {
        return Binder(base) { cv, isHidden in
            cv.backgroundView?.isHidden = isHidden
        }
    }
    
    func zipSelected<T>(_ type: T.Type) -> Observable<(IndexPath, T)> {
        return Observable.zip(
            base.rx.itemSelected.asObservable(),
            base.rx.modelSelected(type).asObservable()
        )
    }
    
    func doubleCheck<T>(_ selected: Observable<T>,
                        value: T) -> Observable<(T, Bool)> {
        return selected
            .takeUntil(
                selected
                    .startWith(value)
                    .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            )
            .startWith(value)
            .take(2)
            .reduce(0) { acc, _ in acc + 1 }
            .map { (value, $0 >= 2) }
    }
}
