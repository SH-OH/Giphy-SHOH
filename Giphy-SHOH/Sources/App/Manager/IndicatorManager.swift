//
//  IndicatorManager.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/02/01.
//

import Foundation
import UIKit.UIActivityIndicatorView

final class IndicatorManager {
    
    private static let shared: IndicatorManager = IndicatorManager()
    private var indicatorView: UIActivityIndicatorView?
    
    static func show() {
        DispatchQueue.main.async {
            guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
                return
            }
            shared.indicatorView?.removeFromSuperview()
            shared.indicatorView = UIActivityIndicatorView().then {
                $0.style = .large
                $0.color = .systemTeal
                $0.startAnimating()
                keyWindow.addSubview($0)
                $0.snp.makeConstraints { (m) in
                    m.center.equalToSuperview()
                }
            }
        }
    }
    
    static func hide() {
        DispatchQueue.main.async {
            shared.indicatorView?.stopAnimating()
            shared.indicatorView?.removeFromSuperview()
        }
    }
}
