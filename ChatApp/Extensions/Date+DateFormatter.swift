//
//  Date+DateFormatter.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 05.03.2022.
//

import Foundation

extension Date {
    /// Переводит  дату в текст с форматированием по маске
    /// - Parameter date: Принимает дату
    /// - Returns: Возвращает дату в виде отформатированной строки
    ///
    /// -- "HH.mm" при текущей дате
    ///
    /// -- "dd.MMM" если дата меньше текущей
    func toString(date: Date) -> String {
        let currentDateCalendar = Calendar.current.compare(
            date,
            to: self,
            toGranularity: .day
        )
        
        let formatter = DateFormatter()
        
        if currentDateCalendar == .orderedSame ||
           currentDateCalendar == .orderedDescending {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "dd.MMM"
        }
        
        return formatter.string(from: date)
    }
}
