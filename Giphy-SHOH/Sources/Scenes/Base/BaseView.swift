//
//  BaseView.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/27.
//

import Foundation
import UIKit.UIView
import RxSwift

class BaseView: UIView {
    var disposeBag: DisposeBag = .init()
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    deinit {
        print("[👋 deinit]\(String(describing: self))")
    }
    
}
