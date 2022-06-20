//
//  ThemeManager.swift
//  ChatApp
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

protocol ThemeManagerProtocol {
    var currentTheme: String? { get set }
    func setupDefaultTheme()
    func appColorSetup(_ theme: Theme, _ colors: AssetsColor) -> UIColor
    func appColorLoadFor(_ name: AssetsColor) -> UIColor
}

// Используется как синглтон, потому что нужен постоянный доступ к текущей теме
// для управления цветами приложения
final class ThemeManager: ThemeManagerProtocol {
    static let shared: ThemeManagerProtocol = ThemeManager()
    
    var currentTheme: String?
    
    private init() {}
    
    func setupDefaultTheme() {
        currentTheme = Theme.classic.rawValue
    }
    
    // делаю возврат красного при неудаче, чтобы сразу было понятно о том, что где-то есть ошибка
    func appColorSetup(_ theme: Theme, _ colors: AssetsColor) -> UIColor {
        let colorName = "\(theme.rawValue) - \(colors.rawValue)"
        return UIColor(named: colorName) ?? .red
    }
    
    func appColorLoadFor(_ name: AssetsColor) -> UIColor {
        guard let currentTheme = currentTheme else {
            Logger.error("Что то не так с присвоением темы")
            return .red
        }

        let theme = currentTheme
        let colorName = "\(theme) - \(name.rawValue)"
        
        return UIColor(named: colorName) ?? .red
     }
    
}
