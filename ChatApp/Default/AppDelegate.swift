//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Дмитрий Данилин on 18.02.2022.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var storageManager: StorageManagerProtocol
    var firstStartAppManager: FirstStartAppManagerProtocol
    var themeManager: ThemeManagerProtocol
    
    override init() {
        self.storageManager = StorageManager()
        self.firstStartAppManager = FirstStartAppManager()
        self.themeManager = ThemeManager.shared
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if CommandLine.arguments.contains("--UITests") {
            UIView.setAnimationsEnabled(false)
        }
        
        FirebaseApp.configure()
        
        setupSchemeColor()
        createAndShowStartVC()
        
        return true
    }
}

// MARK: - Initial application settings

private extension AppDelegate {
    func createAndShowStartVC() {
        let presentationAssembly = PresentationAssembly()
        let channelListVC = presentationAssembly.channelListVC
        
        channelListVC.mySenderID = storageManager.loadUserID()
        
        let navigationController = CustomNavigationController(
            rootViewController: channelListVC
        )
        
        navigationController.navigationBar.scrollEdgeAppearance = navigationController.navigationBar.standardAppearance
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func setupSchemeColor() {
        if firstStartAppManager.isFirstStart() {
            createUserID()
            storageManager.saveTheme(theme: .classic) { _ in
                themeManager.setupDefaultTheme()
            }
            firstStartAppManager.setIsNotFirstStart()
        } else {
            themeManager.currentTheme = storageManager.loadTheme(withKey: .theme)
        }
    }
    
    // TODO: ([27.03.2022]) По хорошему это нужно сделать при создании профиля
    // например при первой загрузке приложения предложить создать профиль
    // и перенаправить на страницу профиля. Где как раз и будет впервые
    // сгенерирован уникальный ID. Не уверен что такие данные можно хранить в userDefaults
    // Скорее всего это должно хранится в профиле на сервере,
    // откуда и будет в дальнейшем производится загрузка идентификатора
    func createUserID() {
        let userID = UIDevice.current.identifierForVendor?.uuidString
        storageManager.saveUserID(userID)
    }
}
