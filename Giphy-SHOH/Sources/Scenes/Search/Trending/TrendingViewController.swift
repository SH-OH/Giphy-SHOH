//
//  TrendingViewController.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/28.
//

import UIKit
import ReactorKit

final class TrendingViewController: BaseViewController {
    
    private enum Constants {
        static let CellHeight: CGFloat = 40
        static let SectionInsetBottom: CGFloat = 100
    }
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .init()
    ).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        $0.collectionViewLayout = layout
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.registerNib(DefaultCell.self)
    }
    
    init(_ reactor: TrendingViewReactor) {
        defer { self.reactor = reactor }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
    }
    
    private func setupView() {
        view.addSubview(collectionView)
    }
    
    private func setupLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - Binding

extension TrendingViewController: View {
    func bind(reactor: TrendingViewReactor) {
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        Observable.just(())
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { Reactor.Action.callGetTrendingSearches }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.trendingSearches }
            .bind(to: collectionView.rx.items(cellIdentifier: DefaultCell.reuseIdentifier, cellType: DefaultCell.self))
            { item, element, cell in
                let isTitle: Bool = item == 0
                cell.configure(element,
                               isTitle: isTitle)
            }.disposed(by: disposeBag)
        
        let sharedZipSelected = collectionView.rx.zipSelected(String.self)
            .filter { $0.0.item != 0 }
            .share(replay: 1)
        
        sharedZipSelected
            .map { SearchViewReactor.Action.enterKeyword($0.1) }
            .bind(to: reactor.searchReactor.action)
            .disposed(by: disposeBag)
        
        sharedZipSelected
            .map { $0.1 }
            .bind(to: reactor.searchReactor.pushControlRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrendingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: collectionView.bounds.width,
            height: Constants.CellHeight
        )
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 0, left: 0,
            bottom: Constants.SectionInsetBottom, right: 0
        )
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
