//
//  ChatCoreDataService.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 02.04.2022.
//

import CoreData

protocol ChatCoreDataServiceProtocol {
    func fetchResultController(
        entityName: String,
        keyForSort: String,
        sortAscending: Bool,
        currentChannel: DBChannel?
    ) -> NSFetchedResultsController<NSFetchRequestResult>
    
    func fetchChannels(from context: NSManagedObjectContext, completion: (Result<[DBChannel], Error>) -> Void)
    func channelSave(_ cannel: Channel, context: NSManagedObjectContext)
    func messageSave(_ message: Message, currentChannel: DBChannel?, context: NSManagedObjectContext)
    func delete(_ currentDBChannel: DBChannel, context: NSManagedObjectContext)
    func performSave(_ block: @escaping (NSManagedObjectContext) -> Void)
}

final class ChatCoreDataService: ChatCoreDataServiceProtocol {
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Chat")
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                Logger.error("\(error)")
            } else {
                Logger.info("\(storeDescription)")
            }
        }
        return container
    }()
    
    private var readContext: NSManagedObjectContext {
        let context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }
    
    private var writheContext: NSManagedObjectContext {
        let context = container.newBackgroundContext()
        return context
    }
    
    func fetchResultController(
        entityName: String,
        keyForSort: String,
        sortAscending: Bool,
        currentChannel: DBChannel? = nil
    ) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let descriptorDateLastActivity = NSSortDescriptor(key: keyForSort, ascending: sortAscending)
        
        fetchRequest.sortDescriptors = [descriptorDateLastActivity]
        
        if let currentChannel = currentChannel {
            fetchRequest.predicate = NSPredicate(format: "%K == %@", "channel", currentChannel)
            fetchRequest.fetchBatchSize = 15
        }
        
        let fetchResultController = NSFetchedResultsController<NSFetchRequestResult>(
            fetchRequest: fetchRequest,
            managedObjectContext: readContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try fetchResultController.performFetch()
        } catch {
            Logger.error(error.localizedDescription)
        }
        
        return fetchResultController
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
        Logger.info("Процесс записи нового канала начался")
        
        let managedObject = NSEntityDescription.insertNewObject(
            forEntityName: String(describing: DBChannel.self),
            into: context
        )
        
        guard let channelDB = managedObject as? DBChannel else {
            Logger.error("Ошибка каста до DBChannel")
            
            return
        }
        
        channelDB.identifier = cannel.identifier
        channelDB.name = cannel.name
        channelDB.lastMessage = cannel.lastMessage
        channelDB.lastActivity = cannel.lastActivity
        
    }
    
    func messageSave(_ message: Message, currentChannel: DBChannel?, context: NSManagedObjectContext) {
        Logger.info("Процесс записи нового сообщения начался")
        
        let managedObject = NSEntityDescription.insertNewObject(
            forEntityName: String(describing: DBMessage.self),
            into: context
        )
        
        guard let messageDB = managedObject as? DBMessage else {
            Logger.error("Ошибка каста до DBMessage")
            
            return
        }
        
        messageDB.content = message.content
        messageDB.created = message.created
        messageDB.senderId = message.senderId
        messageDB.senderName = message.senderName
        messageDB.messageId = message.messageId
        
        if let currentChannel = currentChannel {
            currentChannel.addToMessages(messageDB)
            
            Logger.info("В базу добавлено новое сообщение. Сообщений в базе: \(currentChannel.messages?.count ?? 0)")
        }
        
    }
    
    func delete(_ currentDBChannel: DBChannel, context: NSManagedObjectContext) {
        context.delete(currentDBChannel)
        
        Logger.info("Канал был удалён из базы")
    }
    
    func performSave(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = writheContext
        context.perform { [weak self] in
            block(context)
            Logger.info("Проверка контекста на изменение")
            if context.hasChanges {
                Logger.info("Данные изменены, попытка сохранения")
                do {
                    try self?.performSave(in: context)
                } catch {
                    Logger.error("\(error.localizedDescription)")
                }
            } else {
                Logger.info("Изменений нет")
            }
            
            Logger.info("Проверка контекста на изменение закончена")
        }
    }
    
    private func performSave(in context: NSManagedObjectContext) throws {
        try context.save()
        Logger.info("Данные сохранены")
        
        // Знаю что не используется тут, но просто записал чтобы запомнить на будущее
//        if let parent = context.parent {
//            try performSave(in: parent)
//        }
    }
}
