//
//  StorageManager.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 14.03.2022.
//

import Foundation

final class StorageManager {
    static let shared = StorageManager()
    
    private let userDefaults = UserDefaults()
    
    private init(){}
    
    func saveTheme(theme: Theme) {
        userDefaults.set(theme.rawValue, forKey: "theme")
    }
}
