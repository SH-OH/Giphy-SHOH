//
//  AppConfiguration.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/31.
//

import Foundation
import UIKit.UIApplication

enum AppConfiguration: CaseIterable {
    case Libraries
    
    private var appConfigurable: AppConfigurable.Type {
        switch self {
        case .Libraries: return LibrariesConfiguration.self
        }
    }
}

extension AppConfiguration {
    static func setConfigurations(_ appDelegate: AppDelegate,
                                  application: UIApplication,
                                  launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        AppConfiguration.allCases
            .forEach { configuration in
                configuration
                    .appConfigurable
                    .init()
                    .configuration(
                        appDelegate: appDelegate,
                        application: application,
                        launchOptions: launchOptions
                    )
            }
    }
}
