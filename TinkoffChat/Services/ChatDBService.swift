//
//  ChatDBService.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 02.04.2022.
//

import CoreData

final class ChatDBService {
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
    
    func fetchChannels(completion: (Result<[DBChannel], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<DBChannel> = DBChannel.fetchRequest()
        
        do {
            let channels = try container.viewContext.fetch(fetchRequest)
            completion(.success(channels))
        } catch {
            completion(.failure(error))
        }
    }
    
    func performSave(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = container.newBackgroundContext()
        context.perform { [weak self] in
            block(context)
            if context.hasChanges {
                do {
                    try self?.performSave(in: context)
                } catch {
                    printDebug(error.localizedDescription)
                }
            }
        }
    }
    
    private func performSave(in context: NSManagedObjectContext) throws {
        try context.save()
        
        if let parent = context.parent {
            try performSave(in: parent)
        }
    }
}
