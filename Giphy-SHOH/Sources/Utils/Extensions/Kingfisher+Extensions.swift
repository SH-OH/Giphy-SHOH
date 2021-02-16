//
//  Kingfisher+Extensions.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/31.
//

import Foundation
import Kingfisher
import UIKit

extension AnimatedImageView {
    func setImageAnimated(with url: URL?) {
        self.kf.cancelDownloadTask()
        
        self.kf.setImage(
            with: url,
            options: [.transition(.fade(0.2))]
        )
    }
}
