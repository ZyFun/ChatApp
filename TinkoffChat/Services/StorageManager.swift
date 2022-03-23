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
    }
    
    static let shared = StorageManager()
    // Есть вопрос по синглтону. Когда выполнял задание для поступления в школу,
    // в обратной связи мне написали:
    // "А зачем? Можно же инитить по необходимости"
    // Я долго пытался разобраться что я сделал не так, но у меня так и не получилось.
    // Всё было написано +- тоже самое. Мне нужна более подробная подсказка куда копать ))
    
    private let userDefaults = UserDefaults()
    
    private init() {}
    
    func saveTheme(theme: Theme) {
        DispatchQueue.global().async { [weak self] in
            self?.userDefaults.set(theme.rawValue, forKey: StorageManager.Key.theme.rawValue)
        }
        
        // TODO: Не уверен что это должно быть тут
        ThemeManager.shared.currentTheme = theme.rawValue
    }
    
    func loadTheme(withKey: StorageManager.Key) -> String {
        userDefaults.string(forKey: withKey.rawValue) ?? ""
    }
}
