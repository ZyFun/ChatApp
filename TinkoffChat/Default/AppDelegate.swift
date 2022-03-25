//
//  AppDelegate.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 18.02.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        setupSchemeColorOnFirstStartApp()
        createAndShowStartVC()
        
        return true
    }
}

// MARK: - Initial application settings
private extension AppDelegate {
    func createAndShowStartVC() {
        let ChannelListVC = ChannelListViewController(
            nibName: String(describing: ChannelListViewController.self),
            bundle: nil
        )
        
        let navigationController = CustomNavigationController(
            rootViewController: ChannelListVC
        )
        
        navigationController.navigationBar.scrollEdgeAppearance =  navigationController.navigationBar.standardAppearance
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func setupSchemeColorOnFirstStartApp() {
        if FirstStartAppManager.shared.isFirstStart() {
            FirstStartAppManager.shared.setupDefaultTheme()
            FirstStartAppManager.shared.setIsNotFirstStart()
        }
    }
}

