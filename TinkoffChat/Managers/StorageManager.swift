//
//  StorageManager.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 14.03.2022.
//

import Foundation

final class StorageManager {
    enum Key: String {
        case theme
        case userID
    }
    
    static let shared = StorageManager()
    
    private let userDefaults = UserDefaults()
    
    private init() {}
    
    // MARK: - Theme
    
    func saveTheme(theme: Theme) {
        DispatchQueue.global().async { [weak self] in
            self?.userDefaults.set(theme.rawValue, forKey: StorageManager.Key.theme.rawValue)
        }
        
        // TODO: ([16.03.2022]) Не уверен что это должно быть тут
        ThemeManager.shared.currentTheme = theme.rawValue
    }
    
    func loadTheme(withKey: StorageManager.Key) -> String {
        userDefaults.string(forKey: withKey.rawValue) ?? ""
    }
    
    // MARK: - User ID
    
    func saveUserID(_ userID: String?) {
        userDefaults.set(userID, forKey: Key.userID.rawValue)
    }
    
    func loadUserID() -> String? {
        userDefaults.string(forKey: Key.userID.rawValue)
    }
}
