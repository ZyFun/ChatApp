//
//  AppDelegate.swift
//  TinkoffChat
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
    
    // TODO: ([18.04.2022]) ВОзможно неправильный подход
    // Так-как я не могу сделать инит определенного параметра, использую синглтон
    // и делаю его инит таким образом, потому что он нужен мне именно в этом месте
    // логика такая, первым экраном может поменяться, и чтобы не пришлось переносить код
    // все методы которые я использую на старте приложения, используются именно здесь
    override init() {
        self.storageManager = StorageManager.shared
        self.firstStartAppManager = FirstStartAppManager.shared
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        FirebaseApp.configure()
        
        setupSchemeColorOnFirstStartApp()
        createAndShowStartVC()
        
        return true
    }
}

// MARK: - Initial application settings

private extension AppDelegate {
    func createAndShowStartVC() {
        let ChannelListVC = ChannelListViewController(chatCoreDataService: ChatCoreDataService())
        
        ChannelListVC.mySenderID = storageManager.loadUserID()
        
        let navigationController = CustomNavigationController(
            rootViewController: ChannelListVC
        )
        
        navigationController.navigationBar.scrollEdgeAppearance = navigationController.navigationBar.standardAppearance
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func setupSchemeColorOnFirstStartApp() {
        if firstStartAppManager.isFirstStart() {
            createUserID()
            firstStartAppManager.setupDefaultTheme()
            firstStartAppManager.setIsNotFirstStart()
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
