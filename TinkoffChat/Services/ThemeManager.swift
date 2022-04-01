//
//  ThemeManager.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 14.03.2022.
//

enum Theme: String {
    case classic = "Classic"
    case day = "Day"
    case night = "Night"
}

enum AssetsColor : String {
    case backgroundView
    case backgroundNavBar
    case separator
    case leftMessage
    case rightMessage
    case text
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
}
