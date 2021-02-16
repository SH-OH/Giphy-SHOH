//
//  LibrariesConfiguration.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/31.
//

import Foundation
import Kingfisher
import UIKit.UIApplication

struct LibrariesConfiguration: AppConfigurable {
    func configuration(appDelegate: AppDelegate,
                       application: UIApplication,
                       launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
//        let cache = ImageCache.default
        #if targetEnvironment(simulator)
//        cache.memoryStorage.config.totalCostLimit = 150 * 1024 * 1024
        #else
//        cache.memoryStorage.config.totalCostLimit = 300 * 1024 * 1024
        #endif
    }
}
