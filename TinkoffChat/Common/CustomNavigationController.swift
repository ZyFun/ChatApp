//
//  CustomNavigationController.swift
//  TinkoffChat
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let theme = UserDefaults.standard.string(forKey: "theme")
        
        if theme == Theme.Night.rawValue {
            return .lightContent
        } else {
            return .darkContent
        }
    }
}
