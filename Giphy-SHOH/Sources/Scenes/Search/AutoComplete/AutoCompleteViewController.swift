//
//  AutoCompleteViewController.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/27.
//

import Foundation
import UIKit
import ReactorKit

final class AutoCompleteViewController: BaseViewController {
    
    private enum Constants {
        static let CellHeight: CGFloat = 50
        static let SectionInsetBottom: CGFloat = 100
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.registerNib(DefaultCell.self)
            collectionView.delegate = self
        }
    }
    
}

// MARK: - Binding

extension AutoCompleteViewController: StoryboardView {
    func bind(reactor: AutoCompleteViewReactor) {
        let sharedSearchCurKeyword = reactor.searchReactor.state
            .compactMap { $0.curKeyword }
            .distinctUntilChanged()
            .compactMap { $0.data }
            .share(replay: 1)
        
        sharedSearchCurKeyword
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.getSearchKeywordForAutoComplete($0) }
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        sharedSearchCurKeyword
            .map { $0.isEmpty }
            .asDriverOnEmpty()
            .drive(view.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.autoCompleteData }
            .bind(to: collectionView.rx.items(cellIdentifier: DefaultCell.reuseIdentifier, cellType: DefaultCell.self))
            { item, element, cell in
                let keyword = reactor.searchReactor.currentState.curKeyword.data ?? ""
                cell.configure(element.name,
                               keyword: keyword)
            }.disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(TermData.self)
            .map { $0.name }
            .bind(to: reactor.searchReactor.pushControlRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AutoCompleteViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: collectionView.bounds.width,
            height: Constants.CellHeight
        )
    }
}
