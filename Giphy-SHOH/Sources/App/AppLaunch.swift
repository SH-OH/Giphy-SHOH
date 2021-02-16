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
        let searchReactor = SearchViewReactor(searchNC, useCase: useCase)
        searchVC.reactor = searchReactor
        
        let favoritesVC = FavoritesViewController.storyboard()
        let favoritesNC = BaseNavigationController(favoritesVC)
        let favoritesReactor = FavoritesViewReactor(favoritesNC, useCase: useCase)
        favoritesVC.reactor = favoritesReactor
        
        let navigationControllers = [
            searchNC,
            favoritesNC
        ]
        
        let reactor = MainTabViewReactor(
            navigationControllers: navigationControllers
        )
        
        let mainTabVC = MainTabViewController.storyboard()
        mainTabVC.reactor = reactor
        window.rootViewController = mainTabVC
        window.makeKeyAndVisible()
    }
}
