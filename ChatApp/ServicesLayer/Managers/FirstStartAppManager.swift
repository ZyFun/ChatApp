//
//  FirstStartAppManager.swift
//  ChatApp
//
//  Created by Дмитрий Данилин on 14.03.2022.
//

import Foundation

protocol FirstStartAppManagerProtocol {
    func isFirstStart() -> Bool
    func setIsNotFirstStart()
}

final class FirstStartAppManager: FirstStartAppManagerProtocol {
    func isFirstStart() -> Bool {
        return !UserDefaults.standard.bool(forKey: "isFirstStart")
    }

    func setIsNotFirstStart() {
        UserDefaults.standard.set(true, forKey: "isFirstStart")
    }
}
