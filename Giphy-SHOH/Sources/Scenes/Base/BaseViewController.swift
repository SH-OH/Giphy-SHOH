//
//  BaseViewController.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/25.
//

import Foundation
import UIKit.UIViewController
import RxSwift

class BaseViewController: UIViewController {
    
    var disposeBag: DisposeBag = .init()
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    deinit {
        print("[👋 deinit]\(String(describing: self))")
    }
    
    @objc func actionBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension BaseViewController {
    static func storyboard() -> Self {
        let name = self.reuseIdentifier
        let storyboard = UIStoryboard(name: name, bundle: .main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: name) as? Self else {
            preconditionFailure("Storyboard : '\(name)' init 실패")
        }
        return vc
    }
}
