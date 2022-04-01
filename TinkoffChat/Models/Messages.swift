//
//  Messages.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 07.03.2022.
//

import Foundation

struct Messages {
    let text: String?
    let isIncoming: Bool
    
    static func getMessages() -> [Messages] {
        [
            Messages(
                text: "Привет! Как дела?",
                isIncoming: true
            ),
            Messages(
                text: "Я тестирую как будет отображаться достаточно длинное сообщение, и не будет ли ехать верстка при таком варианте что я напрограммировал",
                isIncoming: true
            ),
            Messages(
                text: "Как, всё хорошо?",
                isIncoming: true
            ),
            Messages(
                text: "Да, отлично!",
                isIncoming: false
            ),
            Messages(
                text: "Осталось только поправить заголовок чата, который почему то резко исчезает при переходе в чат",
                isIncoming: false
            ),
            Messages(
                text: "Ок!",
                isIncoming: true
            ),
            Messages(
                text: "Буду разбираться дальше)",
                isIncoming: true
            )
        ]
    }
}
