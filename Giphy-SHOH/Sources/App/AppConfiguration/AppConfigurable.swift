//
//  AppConfigurable.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/31.
//

import Foundation
import UIKit.UIApplication

protocol AppConfigurable {
    func configuration(appDelegate: AppDelegate,
                       application: UIApplication,
                       launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    
    init()
}
