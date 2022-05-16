//
//  Message.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 25.03.2022.
//

import Foundation

struct Message {
    let content: String
    let created: Date
    let senderId: String
    let senderName: String
    let messageId: String
}
