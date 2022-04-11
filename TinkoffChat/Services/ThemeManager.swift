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

final class ThemeManager {
    static let shared = ThemeManager()
    
    var currentTheme = StorageManager.shared.loadTheme(withKey: .theme)
    
    private init() {}
    
    func appColorSetup(_ theme: Theme, _ colors: AssetsColor) -> UIColor {
        let colorName = "\(theme.rawValue) - \(colors.rawValue)"
        return UIColor(named: colorName) ?? .clear
    }
    
    func appColorLoadFor(_ name: AssetsColor) -> UIColor? {
        let theme = ThemeManager.shared.currentTheme
        let colorName = "\(theme) - \(name.rawValue)"
        
        return UIColor(named: colorName)
     }
}
