//
//  FavoritesViewController.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/25.
//

import Foundation
import UIKit
import ReactorKit

final class FavoritesViewController: BaseViewController {
    
    private enum Constants {
        static let EmptyText: String = "Double Tap Any GIF to save it to\nyour Favorites"
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet { setupCollectionView() }
    }
    
    private func setupCollectionView() {
        collectionView.register(ResultCell.self)
        collectionView.collectionViewLayout = ResultCollectionViewLayout()
        if let layout = collectionView.collectionViewLayout as? ResultCollectionViewLayout {
            layout.delegate = self
        }
        setupEmptyLabel()
    }
    
    private func setupEmptyLabel() {
        _ = UILabel().then {
            $0.text = Constants.EmptyText
            $0.numberOfLines = 2
            $0.textColor = .white
            $0.font = .boldSystemFont(ofSize: 20)
            $0.textAlignment = .center
            $0.center = collectionView.center
            collectionView.backgroundView = $0
        }
    }
    
}

// MARK: - Binding

extension FavoritesViewController: StoryboardView {
    func bind(reactor: FavoritesViewReactor) {
        bindCV(reactor)
        bindDelegate(reactor)
    }
    
    private func bindCV(_ reactor: FavoritesViewReactor) {
        UserDefaults.standard.rx.observe(
            [String].self,
            UserDefaultsType.Favorites().key
        )
        .compactMap { $0 }
        .distinctUntilChanged()
        .filter { $0 != reactor.currentState.favorites }
        .map { Reactor.Action.getUDFavoritesIds($0) }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        // 최초 1회, 전체 리스팅.
        reactor.state.compactMap { $0.favorites }
            .distinctUntilChanged()
            .take(1)
            .map { Reactor.Action.callGetSearchByIds($0) }
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        let sharedData = reactor.state.map { $0.favoritesData }
            .distinctUntilChanged()
            .share(replay: 1)
        
        sharedData
            .bind(to: collectionView.rx.items(cellIdentifier: ResultCell.reuseIdentifier,
                                              cellType: ResultCell.self))
            { item, element, cell in
                cell.configure(element, index: item)
            }.disposed(by: disposeBag)
        
        sharedData
            .map { !$0.isEmpty }
            .asDriverOnEmpty()
            .drive(collectionView.rx.backgroundIsHidden)
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .compactMap { [weak collectionView] in
                collectionView?.cellForItem(at: $0) as? ResultCell
            }
            .observeOn(MainScheduler.instance)
            .bind(onNext: { $0.startAnimation() })
            .disposed(by: disposeBag)
    }
    
    private func bindDelegate(_ reactor: FavoritesViewReactor) {
        let zipSelected = collectionView.rx.zipSelected(SearchData.self)
        let sharedIsDoubleSelected = zipSelected
            .flatMapFirst { [weak collectionView] (value) -> Observable<((IndexPath, SearchData), Bool)> in
                guard let collectionView = collectionView else { return .empty() }
                return collectionView.rx.doubleCheck(zipSelected, value: value)
            }
            .share(replay: 1)
        
        // 더블 탭 - 추가 및 삭제 관련
        sharedIsDoubleSelected
            .filter { $0.1 }
            .map { $0.0.1 }
            .withLatestFrom(
                reactor.state.map { $0.favoritesData },
                resultSelector: { (selectData, data) -> (String, Int)? in
                    if let removeIndex = data.firstIndex(where: { $0.id == selectData.id }) {
                        return (selectData.id, removeIndex)
                    }
                    return nil
                }
            )
            .compactMap { $0 }
            .observeOn(MainScheduler.instance)
            .bind { [weak collectionView] (removeId, removeIndex) in
                let indexPath = IndexPath(item: removeIndex, section: 0)
                
                if let cell = collectionView?.cellForItem(at: indexPath) as? ResultCell {
                    cell.animateFavorites(false, completion: {
                        collectionView?.reloadData()
                        collectionView?.performBatchUpdates {
                            UserDefaultsManager.update(.Favorites(removeId)) {
                                collectionView?.deleteItems(at: [indexPath])
                            }
                        }
                    })
                }
            }.disposed(by: disposeBag)
        
        // 싱글 탭
        sharedIsDoubleSelected
            .filter { !$0.1 }
            .map { $0.0.0 }
            .observeOn(MainScheduler.instance)
            .bind { (indexPath) in
                let detail = DetailViewController.storyboard()
                detail.reactor = DetailViewReactor(
                    searchData: reactor.currentState.favoritesData,
                    selectIndex: indexPath.item
                )
                reactor.navigation.pushViewController(detail)
            }.disposed(by: disposeBag)
        
    }
}

// MARK: - CollectionViewCustomizable

extension FavoritesViewController: CollectionViewCustomizable {
    func collectionView(_ collectionView: UICollectionView,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let reactor = self.reactor else { return .zero }
        guard let item = reactor.currentState.favoritesData[safe: indexPath.item] else {
            return .zero
        }
        
        if let size = reactor.sizeCache[item.id] {
            return size
        }
        
        let width: CGFloat = (collectionView.bounds.width - 6) / 2
        if let size = item.images[.fixedWidth]?.getSize(with: width) {
            reactor.sizeCache.updateValue(size, forKey: item.id)
            return size
        }
        
        return .zero
    }
}

// MARK: - Control UI Events

extension FavoritesViewController {
    func didTapTabButton() {
        if collectionView.contentOffset == .zero {
            collectionView.reloadData()
        } else {
            collectionView.setContentOffset(.zero, animated: true)
        }
    }
}
