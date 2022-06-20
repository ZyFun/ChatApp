//
//  AssemblyService.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 18.05.2022.
//

import Foundation

final class AssemblyService {
    private let coreAssembly = CoreAssembly()
    
    var messageService: MessageServiceProtocol {
        return MessageService(chatFirestore: coreAssembly.chatFirestore)
    }
    
    var channelService: ChannelListServiceProtocol {
        return ChannelListService(chatFirestore: coreAssembly.chatFirestore)
    }
}
