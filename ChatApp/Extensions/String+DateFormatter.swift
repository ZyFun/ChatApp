//
//  String+DateFormatter.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 06.03.2022.
//

import Foundation

extension String {
    /// Переводит строку в дату.
    /// - Parameter format: Принимает строку для форматирования даты по маске.
    /// Значение по умолчанию имеет российский формат.
    /// - Returns: Возвращает дату отформатированную по маске.
    func toDate(withFormat format: String = "dd.MM.yyyy HH:mm") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        return date
    }
}
