//
//  ThemeManager.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 14.03.2022.
//

import Foundation
enum Theme: String {
    case Classic
    case Day
    case Night
}

enum AssetsColor : String {
    case backgroundView
    case backgroundNavBar
    case leftMessage
    case rightMessage
    case text
    case online
    case headerBackground
    case headerText
    case button
}

final class ThemeManager {
    static let shared = ThemeManager()
    
    // TODO: Всю работу по смене тем сделать тут
}
