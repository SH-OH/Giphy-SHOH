//
//  BaseNavigationController.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/26.
//

import Foundation
import UIKit.UINavigationController
import RxSwift

class BaseNavigationController: UINavigationController {
    
    let disposeBag: DisposeBag = .init()
    
    private let backButton = UIBarButtonItem().then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 18,
                                                      weight: .medium)
        $0.image = UIImage(systemName: "chevron.backward",
                           withConfiguration: imageConfig)
            
        $0.style = .plain
        $0.target = nil
        $0.action = nil
    }
    
    init(_ rootViewController: BaseViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        bindBarButton()
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        
        navigationBar.standardAppearance = appearance
        navigationBar.tintColor = .systemTeal
    }
    
    func hiddenBarButton(_ isHidden: Bool) {
        guard let vc = topViewController else { return }
        DispatchQueue.main.async {
            let backBtn: UIBarButtonItem? = isHidden
                ? nil
                : self.backButton
            vc.navigationItem.setLeftBarButton(backBtn, animated: true)
        }
    }
}

// MARK: - Binding
extension BaseNavigationController {
    private func bindBarButton() {
        let sharedWillShow = rx.willShow
            .compactMap { $0.viewController as? BaseViewController }
            .distinctUntilChanged()
            .share(replay: 1)
        
        sharedWillShow
            .asDriverOnEmpty()
            .drive(backButton.rx.updateBackButton)
            .disposed(by: disposeBag)
        
        sharedWillShow
            .map { [weak self] in $0 == self?.viewControllers.first }
            .asDriverOnEmpty()
            .drive(rx.hiddenBarButton)
            .disposed(by: disposeBag)
    }
}

extension BaseNavigationController {
    func pushViewController(_ viewController: BaseViewController,
                            animated: Bool = true,
                            completion: (() -> ())? = nil) {
        self.pushViewController(viewController, animated: animated)
        completion?()
    }
}
