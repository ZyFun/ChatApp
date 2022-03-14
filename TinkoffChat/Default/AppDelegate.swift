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
        
        createAndShowStartVC()
        return true
    }
}

// MARK: - Initial application settings
private extension AppDelegate {
    func createAndShowStartVC() {
        let conversationsListVC = ConversationsListViewController(
            nibName: String(describing: ConversationsListViewController.self),
            bundle: nil
        )
        
        let navigationController = CustomNavigationController(
            rootViewController: conversationsListVC
        )
        
        navigationController.navigationBar.scrollEdgeAppearance =  navigationController.navigationBar.standardAppearance
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

