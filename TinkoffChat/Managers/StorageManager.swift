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

// TODO: ([18.04.2022]) Имеет ли смысл использовать как синглтон?
// чтобы в памяти был только 1 класс, так как при старте приложения он уже висит
// а при переходе на второй экран, появляется еще 1 объект в памяти.
final class StorageManager: StorageManagerProtocol {
    enum Key: String {
        case theme
        case userID
    }
    
    private let userDefaults = UserDefaults()
    
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
