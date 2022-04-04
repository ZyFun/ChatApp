//
//  OldChatCoreDataService.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 04.04.2022.
//

import CoreData

final class OldChatCoreDataService {
    private lazy var managedObjectModel: NSManagedObjectModel? = {
        guard let moduleURL = Bundle.main.url(forResource: "Chat", withExtension: "momd") else { return nil }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: moduleURL) else { return nil }
        
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        guard let managedObjectModel = managedObjectModel  else { return nil }
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        let fileManager = FileManager.default
        let storeName = "Chat.sqlite"
        
        var documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let persistentStoreURL = documentsDirectoryURL?.appendingPathComponent(storeName)
        
        do {
            try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: persistentStoreURL
            )
        } catch {
            printDebug(error.localizedDescription)
        }
        
        return coordinator
    }()
    
    private lazy var readContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }()
    
    private lazy var writeContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        context.mergePolicy = NSOverwriteMergePolicy
        return context
    }()
    
    func fetchChannels(completion: (Result<[DBChannel], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<DBChannel> = DBChannel.fetchRequest()

        do {
            let channels = try readContext.fetch(fetchRequest)
            completion(.success(channels))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchChannels(from context: NSManagedObjectContext, completion: (Result<[DBChannel], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<DBChannel> = DBChannel.fetchRequest()
        
        do {
            let channels = try context.fetch(fetchRequest)
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
        let context = writeContext
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
        
        // Знаю что не используется тут, но просто записал чтобы запомнить на будущее
        if let parent = context.parent {
            try performSave(in: parent)
        }
    }
}
