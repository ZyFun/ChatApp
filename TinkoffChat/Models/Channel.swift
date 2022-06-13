//
//  Channel.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 25.03.2022.
//

import Foundation

struct Channel {
    let identifier: String
    let name: String
    let lastMessage: String?
    let lastActivity: Date?
}
