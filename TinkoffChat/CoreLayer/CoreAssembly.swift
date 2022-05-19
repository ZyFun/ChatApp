//
//  CoreAssembly.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 18.05.2022.
//

import Foundation

final class CoreAssembly {
    var chatFirestore: ChatFirestoreProtocol {
        return ChatFirestore()
    }
}
