//
//  FirstStartAppManager.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 14.03.2022.
//

import Foundation

protocol FirstStartAppManagerProtocol {
    func isFirstStart() -> Bool
    func setIsNotFirstStart()
    func setupDefaultTheme()
}

final class FirstStartAppManager: FirstStartAppManagerProtocol {
    static let shared: FirstStartAppManagerProtocol = FirstStartAppManager()
    
    private init() {}
    
    func isFirstStart() -> Bool {
        return !UserDefaults.standard.bool(forKey: "isFirstStart")
    }

    func setIsNotFirstStart() {
        UserDefaults.standard.set(true, forKey: "isFirstStart")
    }
    
    // TODO: ([18.04.2022]) перенести в менеджер темы
    func setupDefaultTheme() {
        StorageManager.shared.saveTheme(theme: .classic)
    }
}
