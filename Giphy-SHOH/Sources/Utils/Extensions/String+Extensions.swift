//
//  String+Extensions.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/27.
//

import Foundation

extension String {
    func toAttributed(_ attrText: String,
                      attrs: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: self)
        let range = (self as NSString).range(of: attrText)
        attributedText.addAttributes(attrs, range: range)
        return attributedText
    }
}
