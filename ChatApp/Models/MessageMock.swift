//
//  MessageMock.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 07.03.2022.
//

import Foundation

struct MessageMock {
    let text: String?
    let isIncoming: Bool
    
    static func getMessages() -> [MessageMock] {
        [
            MessageMock(
                text: "Привет! Как дела?",
                isIncoming: true
            ),
            MessageMock(
                text: "Я тестирую как будет отображаться достаточно длинное сообщение, и не будет ли ехать верстка при таком варианте что я напрограммировал",
                isIncoming: true
            ),
            MessageMock(
                text: "Как, всё хорошо?",
                isIncoming: true
            ),
            MessageMock(
                text: "Да, отлично!",
                isIncoming: false
            ),
            MessageMock(
                text: "Осталось только поправить заголовок чата, который почему то резко исчезает при переходе в чат",
                isIncoming: false
            ),
            MessageMock(
                text: "Ок!",
                isIncoming: true
            ),
            MessageMock(
                text: "Буду разбираться дальше)",
                isIncoming: true
            )
        ]
    }
}
