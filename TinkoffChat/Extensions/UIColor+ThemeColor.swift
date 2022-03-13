//
//  UIColor+ThemeColor.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 13.03.2022.
//

import UIKit

enum Theme: String {
    case Classic
    case Day
    case Night
}

enum AssetsColor : String {
  case background
  case leftMessage
  case rightMessage
}

extension UIColor {
    static func appColor(_ theme: Theme, _ colors: AssetsColor) -> UIColor {
        let theme = theme.rawValue
        let colorName = "\(theme) - \(colors.rawValue)"//theme + "-" + colors.rawValue
        return UIColor(named: colorName) ?? .clear
    }
}
