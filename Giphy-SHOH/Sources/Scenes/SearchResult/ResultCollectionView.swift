//
//  ResultCollectionView.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/30.
//

import Foundation
import UIKit.UICollectionView
import ReactorKit
import RxCocoa

final class ResultCollectionView: UICollectionView {
    
    private enum Constants {
        static let EmptyText: String = "No GIFs Found"
    }
    
    var disposeBag: DisposeBag = .init()
    
    private var navigation: BaseNavigationController?
    private var sizeCache: [String: CGSize] = [:]
    
    private var layout: ResultCollectionViewLayout? {
        return collectionViewLayout as? ResultCollectionViewLayout
    }
    
    func setup(_ navigation: BaseNavigationController?) {
        register(ResultCell.self)
        collectionViewLayout = ResultCollectionViewLayout()
        if let layout = layout {
            layout.delegate = self
        }
        setupEmptyLabel()
        self.navigation = navigation
    }
    
    private func setupEmptyLabel() {
        _ = UILabel().then {
            $0.text = Constants.EmptyText
            $0.textColor = .white
            $0.font = .boldSystemFont(ofSize: 20)
            $0.textAlignment = .center
            $0.center = self.center
            self.backgroundView = $0
        }
    }
}

extension ResultCollectionView: StoryboardView {
    func bind(reactor: ResultCollectionViewReactor) {
        guard let navigation = self.navigation else { return }
        bindInputData(reactor,
                      navigation: navigation)
        bindOutputData(reactor)
        bindDelegate(reactor)
    }
    
    private func bindInputData(_ reactor: ResultCollectionViewReactor,
                               navigation: BaseNavigationController) {
        reactor.searchReactor.state
            .compactMap { $0.searchType }
            .filter { $0.isCurrentVCIndex(navigation) }
            .distinctUntilChanged()
            .map { $0.data }
            .filter { _ in reactor.searchReactor.isSearchResult }
            .map { Reactor.Action.didSelectSearchType($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.searchReactor.state
            .compactMap { $0.searchedKeyword }
            .filter { $0.isCurrentVCIndex(navigation) }
            .distinctUntilChanged()
            .map { $0.data }
            .distinctUntilChanged()
            .map { Reactor.Action.getSearchKeywordForResultCV($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        let getSearchByKeyword = reactor.state.compactMap { $0.searchKeyword }
            .distinctUntilChanged()
            .withLatestFrom(reactor.state.map { $0.searchType },
                            resultSelector: { ($0, $1) })
        
        let getSearchByType = reactor.state.map { $0.searchType }
            .distinctUntilChanged()
            .withLatestFrom(reactor.state.compactMap { $0.searchKeyword },
                            resultSelector: { ($1, $0) })
        
        Observable.merge(
            getSearchByKeyword,
            getSearchByType
        )
        .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .distinctUntilChanged({ (lhs, rhs) -> Bool in
            let (lKey, lType) = lhs
            let (rKey, rType) = rhs
            return lKey == rKey && lType == rType
        })
        .map { Reactor.Action.callGetSearch($0,
                                               searchType: $1,
                                               apiCallType: .initialize)}
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        rx.willDisplayCell
            .map { $0.at.item }
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .distinctUntilChanged()
            .filter { $0 == reactor.prefetchingCount() }
            .withLatestFrom(reactor.state.map { ($0.searchKeyword, $0.searchType) })
            .map { Reactor.Action.callGetSearch($0,
                                                   searchType: $1,
                                                   apiCallType: .pagination) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindOutputData(_ reactor: ResultCollectionViewReactor) {
        reactor.state
            .compactMap { $0.apiCallType }
            .filter { $0 == .initialize }
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                self?.setContentOffset(.zero, animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.searchData }
            .map { !$0.isEmpty }
            .asDriverOnEmpty()
            .drive(rx.backgroundIsHidden)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.searchData }
            .bind(to: rx.items(cellIdentifier: ResultCell.reuseIdentifier, cellType: ResultCell.self))
            { item, element, cell in
                cell.configure(element, index: item)
            }.disposed(by: disposeBag)
    }
    
    private func bindDelegate(_ reactor: ResultCollectionViewReactor) {
        rx.didEndDisplayingCell
            .compactMap { $0.cell as? ResultCell }
            .bind(onNext: { $0.cancel() })
            .disposed(by: disposeBag)
        
        let zipSelected = rx.zipSelected(SearchData.self).asObservable()
        let sharedIsDoubleSelcted = zipSelected
            .flatMapFirst({ [weak self] (value) -> Observable<((IndexPath, SearchData), Bool)> in
                guard let self = self else { return .empty() }
                return self.rx.doubleCheck(zipSelected, value: value)
            })
            .share(replay: 1)
        
        // 더블 탭
        sharedIsDoubleSelcted
            .filter { $0.1 }
            .map { $0.0 }
            .observeOn(MainScheduler.instance)
            .bind { [weak self] (indexPath, model) in
                if let cell = self?.cellForItem(at: indexPath) as? ResultCell {
                    // 셀 선택 시, gif 애니메이션이 pausing 됨. 원인 분석이 좀 더 필요함.
                    cell.startAnimation()
                    
                    if let isEmpty = UserDefaultsManager.update(.Favorites(model.id)) {
                        cell.animateFavorites(isEmpty)
                    }
                }
            }.disposed(by: disposeBag)
        
        // 싱글 탭
        sharedIsDoubleSelcted
            .filter { !$0.1 }
            .map { $0.0.0 }
            .observeOn(MainScheduler.instance)
            .bind { [weak self] (indexPath) in
                if let cell = self?.cellForItem(at: indexPath) as? ResultCell {
                    // 셀 선택 시, gif 애니메이션이 pausing 됨. 원인 분석이 좀 더 필요함.
                    cell.startAnimation()
                }
                let detail = DetailViewController.storyboard()
                detail.reactor = DetailViewReactor(
                    searchData: reactor.currentState.searchData,
                    selectIndex: indexPath.item
                )
                self?.navigation?.pushViewController(detail)
            }.disposed(by: disposeBag)
    }
}

// MARK: - CollectionViewCustomizable

extension ResultCollectionView: CollectionViewCustomizable {
    func collectionView(_ collectionView: UICollectionView,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let reactor = self.reactor else { return .zero }
        guard let item = reactor.currentState.searchData[safe: indexPath.item] else {
            return .zero
        }
        
        if let size = sizeCache[item.id] {
            return size
        }
        
        let width: CGFloat = (collectionView.bounds.width - 6) / 2
        if let size = item.images[.fixedWidth]?.getSize(with: width) {
            sizeCache.updateValue(size, forKey: item.id)
            return size
        }
        
        return .zero
    }
}
