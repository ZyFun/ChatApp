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
    
    // Всё еще не до конца понимаю что должно быть в моделе
    // вроде этот код и к бизнес логике относится, а вроде бы и к слою
    // который получает данные из базы и взаимодействует с базой
    // и должен находится в менеджере. Так и не смог найти адекватного примера
    // в котором было бы показано как нужно распределять код в MVC :(
    
    static func loadMessagesFromFirebase(
        for currentChannel: DBChannel?,
        with firebaseService: FirestoreServiceProtocol,
        and chatCoreDataService: ChatCoreDataServiceProtocol,
        completion: @escaping () -> Void
    ) {
        guard let channelID = currentChannel?.identifier else {
            Logger.error("Отсутствует идентификатор канала")
            return
        }
        
        firebaseService.fetchMessages(
            channelID: channelID
        ) { result in
            switch result {
            case .success(let messages):
                Logger.info("Данные из Firebase загружены")
                saveLoaded(
                    messages,
                    for: currentChannel,
                    with: chatCoreDataService
                )
                
                completion()
            case .failure(let error):
                Logger.error(error.localizedDescription)
            }
        }
    }
    
    static func saveLoaded(
        _ messages: [Message],
        for currentChannel: DBChannel?,
        with chatCoreDataService: ChatCoreDataServiceProtocol
    ) {
        Logger.info("=====Процесс обновления сообщений в CoreData запущен=====")
        guard let channelID = currentChannel?.identifier else {
            Logger.error("Отсутствует идентификатор канала")
            return
        }
        
        chatCoreDataService.performSave { context in
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
            
            messages.forEach { message in
                
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
