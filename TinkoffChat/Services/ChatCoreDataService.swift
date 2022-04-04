//
//  ChatCoreDataService.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 02.04.2022.
//

import CoreData

final class ChatCoreDataService {
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Chat")
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                printDebug(error)
            } else {
                printDebug(storeDescription)
            }
        }
        return container
    }()
    
    func fetchChannels(from context: NSManagedObjectContext, completion: (Result<[DBChannel], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<DBChannel> = DBChannel.fetchRequest()
        
        do {
            let channels = try context.fetch(fetchRequest)
            completion(.success(channels))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchChannels(completion: (Result<[DBChannel], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<DBChannel> = DBChannel.fetchRequest()
        
        do {
            let channels = try container.viewContext.fetch(fetchRequest)
            completion(.success(channels))
        } catch {
            completion(.failure(error))
        }
    }
    
    func channelSave(_ cannel: Channel, context: NSManagedObjectContext) {
        let channelDB = DBChannel(context: context)
        
        channelDB.identifier = cannel.identifier
        channelDB.name = cannel.name
        channelDB.lastMessage = cannel.lastMessage
        channelDB.lastActivity = cannel.lastActivity
    }
    
    func messageSave(_ message: Message, currentChannel: DBChannel?, context: NSManagedObjectContext) {
        printDebug("Процесс записи нового сообщения начался")
        let managedObject = NSEntityDescription.insertNewObject(
            forEntityName: String(describing: DBMessage.self),
            into: context
        )
        
        guard let messageDB = managedObject as? DBMessage else {
            printDebug("Ошибка каста до DBMessage")
            return
        }
        
        messageDB.content = message.content
        messageDB.created = message.created
        messageDB.senderId = message.senderId
        messageDB.senderName = message.senderName
        
        if let currentChannel = currentChannel {
            currentChannel.addToMessages(messageDB)
            printDebug("В базу добавлено новое сообщение")
            printDebug("Текущее количество сообщений в базе: \(currentChannel.messages?.count ?? 0)")
        }
        
    }
    
    func performSave(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = container.newBackgroundContext()
        context.perform { [weak self] in
            block(context)
            printDebug("Проверка контекста на изменение")
            if context.hasChanges {
                printDebug("Данные изменены, попытка сохранения")
                do {
                    try self?.performSave(in: context)
                } catch {
                    printDebug(error.localizedDescription)
                }
            } else {
                printDebug("Изменений нет")
            }
            printDebug("Проверка контекста на изменение закончена")
        }
    }
    
    private func performSave(in context: NSManagedObjectContext) throws {
        try context.save()
        printDebug("Данные сохранены")
        
        if let parent = context.parent {
            try performSave(in: parent)
        }
    }
}
