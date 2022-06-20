//
//  String+SearchingLink.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 27.04.2022.
//

import Foundation

extension String {
    /// Метод производит поиск ссылки в тексте, разбив предложение на компоненты
    /// - Returns: возвращает найденную ссылку в текстовом формате
    /// - Корректно работает для 1 ссылки в сообщении
    func searchingLink() -> String {
        var url = ""
        let components = self.components(separatedBy: " ")
        for component in components where component.contains("http") {
            url = component
        }
        return url
    }
}
