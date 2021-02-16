//
//  NibUsable.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/31.
//

import Foundation
import UIKit.UIView

protocol NibUsable {}

extension NibUsable {
    private static func nibName() -> String {
        return String(describing: self)
    }
}

extension NibUsable where Self: UIView {
    static func nib() -> Self {
        let bundle = Bundle(for: self)
        let _nib = bundle.loadNibNamed(nibName(), owner: self, options: nil)
        
        return _nib!.first as! Self
    }
}
