//
//  UIColor+ThemeColor.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 13.03.2022.
//

import UIKit

extension UIColor {
    static func appColorSetup(_ theme: Theme, _ colors: AssetsColor) -> UIColor {
        let colorName = "\(theme.rawValue) - \(colors.rawValue)"
        return UIColor(named: colorName) ?? .clear
    }
    
    static func appColorLoadFor(_ name: AssetsColor) -> UIColor? {
        let theme = StorageManager.shared.loadTheme(withKey: .theme)
        let colorName = "\(theme) - \(name.rawValue)"
        
        return UIColor(named: colorName)
     }
}
