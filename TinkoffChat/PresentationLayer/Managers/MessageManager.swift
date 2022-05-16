//
//  MessageManager.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 20.04.2022.
//

protocol MessageManagerProtocol {
    func loadMessagesFromFirebase(
        for currentChannel: DBChannel?,
        with chatCoreDataService: ChatCoreDataServiceProtocol,
        completion: @escaping () -> Void
    )
    
    func sendMessage(
        channelID: String,
        senderID: String,
        message: String,
        completion: () -> Void
    )
}

final class MessageManager: MessageManagerProtocol {
    private var messages: [Message] = []
    private let firebaseService: FirestoreServiceProtocol
    
    init() {
        firebaseService = FirestoreService()
    }
    
    func loadMessagesFromFirebase(
        for currentChannel: DBChannel?,
        with chatCoreDataService: ChatCoreDataServiceProtocol,
        completion: @escaping () -> Void
    ) {
        guard let channelID = currentChannel?.identifier else {
            Logger.error("Отсутствует идентификатор канала")
            return
        }
        
        firebaseService.fetchMessages(
            channelID: channelID
        ) { [weak self] result in
            switch result {
            case .success(let messages):
                Logger.info("Данные из Firebase загружены")
                self?.messages = messages
                
                Logger.info("Сохранение загруженных данных в CoreData")
                self?.saveLoadedMessages(
                    for: currentChannel,
                    with: chatCoreDataService
                )
                
                completion()
            case .failure(let error):
                Logger.error(error.localizedDescription)
            }
        }
    }
    
    func sendMessage(
        channelID: String,
        senderID: String,
        message: String,
        completion: () -> Void
    ) {
        firebaseService.sendMessage(
            channelID: channelID,
            message: message,
            senderID: senderID
        )
        
        completion()
    }
    
    private func saveLoadedMessages(
        for currentChannel: DBChannel?,
        with chatCoreDataService: ChatCoreDataServiceProtocol
    ) {
        Logger.info("=====Процесс обновления сообщений в CoreData запущен=====")
        guard let channelID = currentChannel?.identifier else {
            Logger.error("Отсутствует идентификатор канала")
            return
        }
        
        chatCoreDataService.performSave { [weak self] context in
            var messagesDB: [DBMessage] = []
            var currentChannel: DBChannel?
            
            chatCoreDataService.fetchChannels(from: context) { result in
                switch result {
                case .success(let channels):
                    if let channel = channels.filter({ $0.identifier == channelID }).first {
                        currentChannel = channel
                        
                        Logger.info("Загружено сообщений из базы: \(channel.messages?.count ?? 0)")
                        
                        if let channelMessages = channel.messages?.allObjects as? [DBMessage] {
                            messagesDB = channelMessages
                        }
                    }
                case .failure(let error):
                    Logger.error("\(error.localizedDescription)")
                }
            }
            
            Logger.info("Запуск процесса поиска новых данных")
            
            self?.messages.forEach { message in
                
                guard messagesDB.filter({
                    $0.messageId == message.messageId
                }).first == nil else {
                    Logger.info("Сообщение уже есть в базе")
                    return
                }
                
                Logger.info("Найдено новое сообщение")
                chatCoreDataService.messageSave(
                    message,
                    currentChannel: currentChannel,
                    context: context
                )
            }
        }
    }
}
