//
//  ThemeManager.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 14.03.2022.
//

import UIKit

enum Theme: String {
    case classic = "Classic"
    case day = "Day"
    case night = "Night"
}

enum AssetsColor: String {
    case backgroundView
    case backgroundNavBar
    case backgroundToolBar
    case textFieldToolBar
    case separator
    case leftMessage
    case rightMessage
    case senderName
    case text
    case dateCreated
    case textImageView
    case online
    case headerBackground
    case headerText
    case button
    case buttonNavBar
    case profileImageView
}

// Используется как синглтон, потому то нужен постоянный доступ к текущей теме
// для управления цветами приложения
final class ThemeManager {
    static let shared = ThemeManager()
    
    var currentTheme = StorageManager.shared.loadTheme(withKey: .theme)
    
    private init() {}
    
    func setupDefaultTheme() {
        StorageManager.shared.saveTheme(theme: .classic) { theme in
            currentTheme = theme.rawValue
        }
    }
    
    func appColorSetup(_ theme: Theme, _ colors: AssetsColor) -> UIColor {
        let colorName = "\(theme.rawValue) - \(colors.rawValue)"
        return UIColor(named: colorName) ?? .red
    }
    
    func appColorLoadFor(_ name: AssetsColor) -> UIColor {
        let theme = currentTheme
        let colorName = "\(theme) - \(name.rawValue)"
        
        return UIColor(named: colorName) ?? .red
     }
    
    // делаю возврат красного, чтобы сразу было понятно о том, что где-то есть ошибка
}
