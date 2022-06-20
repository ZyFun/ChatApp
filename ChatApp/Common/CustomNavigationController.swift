//
//  CustomNavigationController.swift
//  ChatApp
//
//  Created by Дмитрий Данилин on 14.03.2022.
//

import UIKit

/// Используется для того, чтобы была возможность менять цвет статус бара в ручную через код
final class CustomNavigationController: UINavigationController {
    // Для смены цвета статус бара не глобально
    /*
    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
    */
    
    private let themeManager: ThemeManagerProtocol
    
    override init(rootViewController: UIViewController) {
        self.themeManager = ThemeManager.shared
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let currentTheme = themeManager.currentTheme
        
        if currentTheme == Theme.night.rawValue {
            return .lightContent
        } else {
            return .darkContent
        }
    }
}
