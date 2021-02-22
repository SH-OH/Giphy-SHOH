//
//  MainTabViewController.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/26.
//

import Foundation
import UIKit
import ReactorKit
import Then

final class MainTabViewController: BaseViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var viewControllersSV: UIStackView!
    @IBOutlet private weak var tabBarSV: UIStackView!
    
    var navigationControllers: [BaseNavigationController]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers(viewControllersSV)
        addGradiation(to: tabBarSV)
    }
    
    private func setupViewControllers(_ vcsSV: UIStackView) {
        navigationControllers?
            .enumerated().forEach { (index, nc) in
                guard let _view = vcsSV.arrangedSubviews[safe: index] else { return }
                nc.willMove(toParent: self)
                nc.view.frame = _view.bounds
                self.addChild(nc)
                _view.addSubview(nc.view)
                nc.didMove(toParent: self)
            }
    }
    
    private func addGradiation(to sv: UIStackView) {
        let black: UIColor = .black
        let colors: [CGColor] = [
            UIColor.clear,
            black.withAlphaComponent(0.95),
            black
        ].map { $0.cgColor }
        let locations: [NSNumber] = [0.0, 0.7, 1]
            .map { NSNumber(value: $0) }
        
        sv.layoutIfNeeded()
        
        _ = CAGradientLayer().then {
            $0.frame = sv.bounds
            $0.zPosition = -1
            $0.startPoint = CGPoint(x: 0.5, y: 0)
            $0.endPoint = CGPoint(x: 0.5, y: 1)
            $0.colors = colors
            $0.locations = locations
            sv.layer.addSublayer($0)
        }
    }
    
}

// MARK: - Binding

extension MainTabViewController: StoryboardView {
    
    func bind(reactor: MainTabViewReactor) {
        bindTabButton(reactor)
    }
    
    private func bindTabButton(_ reactor: MainTabViewReactor) {
        let observableTabBtns: [Observable<TabButtonType>] = TabButtonType.allCases
            .compactMap { [weak tabBarSV] (type) -> Observable<TabButtonType>? in
                guard let button = tabBarSV?
                        .arrangedSubviews[safe: type.rawValue] as? UIButton else {
                    return nil
                }
                return button.rx.tap.map { type }
            }
        
        Observable.merge(observableTabBtns)
            .map { Reactor.Action.didTapTabButton($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        let sharedDidTapTabButton = reactor.state.map { $0.curTabButton }
            .withLatestFrom(reactor.state.map { $0.prevTabButton },
                            resultSelector: { ($1, $0) })
            .share(replay: 1)
        
        // 같은 탭 선택
        sharedDidTapTabButton
            .filter { $0.0 == $0.1 }
            .observeOn(MainScheduler.instance)
            .bind { [weak self] (prev, cur) in
                guard let navigationControllers = self?.navigationControllers else { return }
                let navigation = cur.navigation(navigationControllers)
                if let favVC = navigation.topViewController as? FavoritesViewController {
                    favVC.didTapTabButton()
                }
                navigation.popToRootViewController(animated: true)
            }.disposed(by: disposeBag)
        
        // 다른 탭 선택
        sharedDidTapTabButton
            .filter { $0.0 != $0.1 }
            .observeOn(MainScheduler.instance)
            .bind { [weak view, weak scrollView] (prev, cur) in
                guard let view = view else { return }
                let x = view.bounds.width * CGFloat(cur.scrollIndex)
                let point: CGPoint = CGPoint(x: x, y: 0)
                scrollView?.setContentOffset(point, animated: true)
            }.disposed(by: disposeBag)
    }
}
