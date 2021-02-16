//
//  DetailViewController.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/02/01.
//

import Foundation
import UIKit.UIViewController
import ReactorKit

final class DetailViewController: BaseViewController {
    
    private enum Constants {
        static let CellWidthPadding: CGFloat = 50
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet { self.setupCollectionView() }
    }
    
    private func setupCollectionView() {
        collectionView.register(ResultCell.self)
        collectionView.collectionViewLayout = DetailCollectionViewLayout()
        if let layout = collectionView.collectionViewLayout as? DetailCollectionViewLayout {
            layout.delegate = self
            layout.startIndex = reactor?.selectIndex ?? 0
        }
    }
}

// MARK: - Binding

extension DetailViewController: StoryboardView {
    func bind(reactor: DetailViewReactor) {
        bindVC(reactor)
        bindCV(reactor)  
    }
    
    private func bindVC(_ reactor: DetailViewReactor) {
        collectionView.rx.contentOffset
            .map { [weak collectionView] in
                round($0.x / (collectionView?.bounds.width ?? 0))
            }
            .distinctUntilChanged()
            .map { Int($0) }
            .withLatestFrom(reactor.state.map { $0.searchDataInDetail },
                            resultSelector: { $1[safe: $0] })
            .compactMap { $0?.isStickerBoolValue }
            .map { $0 ? "Sticker" : "GIF" }
            .asDriverOnEmpty()
            .drive(rx.title)
            .disposed(by: disposeBag)
    }
    
    private func bindCV(_ reactor: DetailViewReactor) {
        reactor.state.map { $0.searchDataInDetail }
            .bind(to: collectionView.rx.items(cellIdentifier: ResultCell.reuseIdentifier, cellType: ResultCell.self))
            { item, element, cell in
                cell.configure(element, index: item)
            }.disposed(by: disposeBag)
        
        let zipSelected = collectionView.rx.zipSelected(SearchData.self)
        
        zipSelected
            .flatMapFirst { [weak collectionView] value -> Observable<((IndexPath, SearchData), Bool)> in
                guard let collectionView = collectionView else { return .empty() }
                return collectionView.rx.doubleCheck(zipSelected, value: value)
            }
            .bind { [weak collectionView] (arg0, isDouble) in
                let (indexPath, model) = arg0
                if let cell = collectionView?.cellForItem(at: indexPath) as? ResultCell {
                    // 셀 선택 시, gif 애니메이션이 pausing 됨. 원인 분석이 좀 더 필요함.
                    cell.startAnimation()
                    if isDouble,
                       let isEmpty = UserDefaultsManager.update(.Favorites(model.id)) {
                        cell.animateFavorites(isEmpty)
                    }
                }
            }.disposed(by: disposeBag)
        
        reactor.state.map { $0.searchDataInDetail }
            .take(1)
            .map { _ in IndexPath(item: reactor.selectIndex, section: 0) }
            .observeOn(MainScheduler.instance)
            .bind { [weak collectionView] (startIndexPath) in
                collectionView?.scrollToItem(
                    at: startIndexPath,
                    at: .centeredHorizontally,
                    animated: false
                )
            }.disposed(by: disposeBag)
    }
}

// MARK: - CollectionViewCustomizable

extension DetailViewController: CollectionViewCustomizable {
    func collectionView(_ collectionView: UICollectionView,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let reactor = self.reactor else { return .zero }
        guard let item = reactor.currentState.searchDataInDetail[safe: indexPath.item] else {
            return .zero
        }
        
        if let size = reactor.sizeCache[item.id] {
            return size
        }
        
        let width: CGFloat = collectionView.bounds.width - Constants.CellWidthPadding
        if let size: CGSize = item.images[.fixedWidth]?.getSize(with: width) {
            reactor.sizeCache.updateValue(size, forKey: item.id)
            return size
        }
        
        return .zero
    }
}
