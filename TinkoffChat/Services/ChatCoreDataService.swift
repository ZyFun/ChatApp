//
//  ChatCoreDataService.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 02.04.2022.
//

import CoreData

final class ChatCoreDataService {
    /// Свойство для активации и отображения логов в данном классе
    private var isLogActivate = true
    
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Chat")
        container.loadPersistentStores { [weak self] storeDescription, error in
            if let error = error {
                Logger.error(
                    "\(error)",
                    shouldLogContext: self?.isLogActivate
                )
            } else {
                Logger.info(
                    "\(storeDescription)",
                    shouldLogContext: self?.isLogActivate
                )
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
        Logger.info(
            "Процесс записи нового канала начался",
            showInConsole: isLogActivate
        )
        
        let managedObject = NSEntityDescription.insertNewObject(
            forEntityName: String(describing: DBChannel.self),
            into: context
        )
        
        guard let channelDB = managedObject as? DBChannel else {
            Logger.error(
                "Ошибка каста до DBChannel",
                showInConsole: isLogActivate
            )
            
            return
        }
        
        channelDB.identifier = cannel.identifier
        channelDB.name = cannel.name
        channelDB.lastMessage = cannel.lastMessage
        channelDB.lastActivity = cannel.lastActivity
        
    }
    
    func messageSave(_ message: Message, currentChannel: DBChannel?, context: NSManagedObjectContext) {
        Logger.info(
            "Процесс записи нового сообщения начался",
            showInConsole: isLogActivate
        )
        
        let managedObject = NSEntityDescription.insertNewObject(
            forEntityName: String(describing: DBMessage.self),
            into: context
        )
        
        guard let messageDB = managedObject as? DBMessage else {
            Logger.error(
                "Ошибка каста до DBMessage",
                showInConsole: isLogActivate
            )
            
            return
        }
        
        messageDB.content = message.content
        messageDB.created = message.created
        messageDB.senderId = message.senderId
        messageDB.senderName = message.senderName
        
        if let currentChannel = currentChannel {
            currentChannel.addToMessages(messageDB)
            
            Logger.info(
                "В базу добавлено новое сообщение. Сообщений в базе: \(currentChannel.messages?.count ?? 0)",
                showInConsole: isLogActivate
            )
        }
        
    }
    
    func delete(_ currentDBChannel: DBChannel, context: NSManagedObjectContext) {
        context.delete(currentDBChannel)
        
        Logger.info(
            "Канал был удалён из базы",
            showInConsole: isLogActivate
        )
    }
    
    func performSave(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = container.newBackgroundContext()
        context.perform { [weak self] in
            block(context)
            Logger.info(
                "Проверка контекста на изменение",
                showInConsole: self?.isLogActivate
            )
            if context.hasChanges {
                Logger.info(
                    "Данные изменены, попытка сохранения",
                    showInConsole: self?.isLogActivate
                )
                do {
                    try self?.performSave(in: context)
                } catch {
                    Logger.error(
                        "\(error.localizedDescription)",
                        showInConsole: self?.isLogActivate
                    )
                }
            } else {
                Logger.info(
                    "Изменений нет",
                    showInConsole: self?.isLogActivate
                )
            }
            
            Logger.info(
                "Проверка контекста на изменение закончена",
                showInConsole: self?.isLogActivate
            )
        }
    }
    
    private func performSave(in context: NSManagedObjectContext) throws {
        try context.save()
        Logger.info(
            "Данные сохранены",
            showInConsole: isLogActivate
        )
        
        // Знаю что не используется тут, но просто записал чтобы запомнить на будущее
//        if let parent = context.parent {
//            try performSave(in: parent)
//        }
    }
}
