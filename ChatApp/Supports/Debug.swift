//
//  Debug.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 18.02.2022.
//

/// Выводит печать в консоль, только при использовании дебага.
/// - Это позволяет расходовать меньше ресурсов айфона, если не убрать принты из кода.
public func printDebug(_ items: Any...) {
    #if DEBUG
    for item in items {
        Swift.print(item)
    }
    #endif
}
