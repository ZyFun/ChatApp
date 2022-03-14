//
//  FirstStartAppManager.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 14.03.2022.
//

import Foundation

final class FirstStartAppManager {
    static let shared = FirstStartAppManager()
    
    private init(){}
    
    func isFirstStart() -> Bool{
        return !UserDefaults.standard.bool(forKey: "isFirstStart")
    }

    func setIsNotFirstStart() {
        UserDefaults.standard.set(true, forKey: "isFirstStart")
    }
    
    func setupDefaultTheme() {
        StorageManager.shared.saveTheme(theme: .Classic)
    }
}


