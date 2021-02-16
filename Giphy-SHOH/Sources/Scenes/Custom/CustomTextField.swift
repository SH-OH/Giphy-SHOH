//
//  CustomTextField.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/26.
//

import Foundation
import UIKit.UITextField

@IBDesignable
class CustomTextField: UITextField {
    
    @IBInspectable
    private var _inset: CGFloat {
        get {
            return inset
        }
        set {
            inset = newValue
        }
    }
    private var inset: CGFloat = 10
    
    @IBInspectable
    private var _placeholderColor: UIColor {
        get {
            return .systemGray
        }
        set {
            attributedPlaceholder = NSAttributedString(
                string: placeholder ?? "",
                attributes: [
                    .foregroundColor: newValue
                ]
            )
        }
    }
    
    // MARK: - Padding
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let insets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        return bounds.inset(by: insets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let insets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        return bounds.inset(by: insets)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let insets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        return bounds.inset(by: insets)
    }
}
