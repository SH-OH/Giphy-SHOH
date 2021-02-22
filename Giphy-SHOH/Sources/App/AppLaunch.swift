//
//  AppLaunch.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/25.
//

import Foundation
import UIKit.UIWindow

struct AppLaunch {
    static func launch(_ window: UIWindow) {
        let useCase = GiphyUseCase(.init())
        
        let searchVC = SearchViewController.storyboard()
        let searchNC = BaseNavigationController(searchVC)
        searchVC.navigation = searchNC
        let searchReactor = SearchViewReactor(useCase)
        searchVC.reactor = searchReactor
        
        let favoritesVC = FavoritesViewController.storyboard()
        let favoritesNC = BaseNavigationController(favoritesVC)
        favoritesVC.navigation = favoritesNC
        let favoritesReactor = FavoritesViewReactor(useCase)
        favoritesVC.reactor = favoritesReactor
        
        let navigationControllers = [
            searchNC,
            favoritesNC
        ]
        
        let mainTabVC = MainTabViewController.storyboard()
        mainTabVC.navigationControllers = navigationControllers
        mainTabVC.reactor = MainTabViewReactor()
        window.rootViewController = mainTabVC
        window.makeKeyAndVisible()
    }
}
