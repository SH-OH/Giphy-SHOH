//
//  TypeButton.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/27.
//

import Foundation
import UIKit.UIButton
import RxCocoa
import RxSwift
import ReactorKit

final class TypeButton: UIButton, NibUsable {
    
    var disposeBag: DisposeBag = .init()
    
    private(set) var titleSize: CGSize = .zero
    
}

extension TypeButton: StoryboardView {
    func bind(reactor: TypeButtonReactor) {
        reactor.state.map { $0.title }
            .do(onSubscribed: { [weak self] in
                self?.titleSize = self?.titleLabel?.intrinsicContentSize ?? .zero
            })
            .asDriverOnEmpty()
            .drive(rx.title(for: .normal))
            .disposed(by: disposeBag)
    }
}
