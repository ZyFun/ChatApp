//
//  StorageManager.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 14.03.2022.
//

import Foundation

protocol StorageManagerProtocol {
    func saveTheme(theme: Theme, completion: (Theme) -> Void)
    func loadTheme(withKey: StorageManager.Key) -> String
    func saveUserID(_ userID: String?)
    func loadUserID() -> String?
}

final class StorageManager: StorageManagerProtocol {
    enum Key: String {
        case theme
        case userID
    }
    
    static let shared: StorageManagerProtocol = StorageManager()
    
    private let userDefaults = UserDefaults()
    
    private init() {}
    
    // MARK: - Theme
    
    func saveTheme(theme: Theme, completion: (Theme) -> Void) {
        DispatchQueue.global().async { [weak self] in
            self?.userDefaults.set(
                theme.rawValue,
                forKey: Key.theme.rawValue
            )
        }
        
        // Возврат выбранной темы, для установки текущей темы
        completion(theme)
    }
    
    func loadTheme(withKey: Key) -> String {
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
