//
//  Messages.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 07.03.2022.
//

import Foundation

struct Messages {
    let message: String?
    let isIncoming: Bool
    
    static func getMessages() -> [Messages] {
        [
            Messages(
                message: "Привет! Как дела?",
                isIncoming: true
            ),
            Messages(
                message: "Я тестирую как будет отображаться достаточно длинное сообщение, и не будет ли ехать верстка при таком варианте что я напрограммировал",
                isIncoming: true
            ),
            Messages(
                message: "Как, всё хорошо?",
                isIncoming: true
            ),
            Messages(
                message: "Да, отлично!",
                isIncoming: false
            ),
            Messages(
                message: "Ок!",
                isIncoming: true
            ),
            Messages(
                message: "Буду разбираться дальше)",
                isIncoming: true
            )
        ]
    }
}
