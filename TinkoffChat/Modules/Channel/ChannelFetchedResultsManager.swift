//
//  FetchResultManager.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 14.04.2022.
//

import UIKit
import CoreData

protocol ChannelFetchedResultsManagerProtocol {
    var tableView: UITableView? { get set }
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> { get set }
    var mySenderId: String? { get set }
}

final class ChannelFetchedResultsManager: NSObject, NSFetchedResultsControllerDelegate, ChannelFetchedResultsManagerProtocol {
    var tableView: UITableView?
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    var mySenderId: String?
    
    private var cacheManager: ImageLoadingManagerProtocol
    
    // MARK: - Initializer
    
    init(fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>) {
        self.fetchedResultsController = fetchedResultsController
        cacheManager = ImageLoadingManager()
        super.init()
        self.fetchedResultsController.delegate = self
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView?.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView?.deleteRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath {
                tableView?.deleteRows(at: [indexPath], with: .automatic)
            }

            if let newIndexPath = newIndexPath {
                tableView?.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                let message = fetchedResultsController.object(at: indexPath) as? DBMessage
                let cell = tableView?.cellForRow(at: indexPath) as? MessageCell
                
                // TODO: ([26.04.2022]) Тестовый вариант кода. Сделать методом и перенести в слой менеджера
                
                var image: UIImage?
                // Используется для отображения ошибки, если со ссылкой что-то не так
                var textMessage = message?.content
                
                if let message = message?.content {
                    if message.contains("http") {
                        let  messageComponents = message.components(separatedBy: " ")
                        for component in messageComponents where component.contains("http") {
                            cacheManager.getImage(from: component) { result in
                                switch result {
                                case .success(let loadedImage):
                                    image = loadedImage
                                case .failure(let error):
                                    // не всё отображается корректно, так как по некоторым запросам
                                    // сервер пытается достучатся дальше, а в ячейке уже отображены данные из базы
                                    // этот код должен выполнятся при переиспользовании ячейки
                                    // заменяя полученный из базы текст собой. Аналогично и с изображением
                                    // по хорошему, нужно просто возвращать true и если верно,
                                    // хапускать загрузку изображения
                                    textMessage = error.rawValue
                                    Logger.error(error.rawValue)
                                }
                            }
                        }
                    }
                }
                
                cell?.configureMessageCell(
                    senderName: message?.senderName,
                    imageMessage: image, // TODO: ([26.04.2022]) скорее всего нужно будет не передавать сюда, а грузить уже в поцессе
                    // или передавать значение тру и отображать плейсхолдер с загрузкой
                    textMessage: textMessage ?? "",
                    dateCreated: message?.created ?? Date(),
                    isIncoming: message?.senderId != mySenderId
                )
            }
        @unknown default:
            Logger.error("Что то пошло не так в NSFetchedResultsControllerDelegate")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
}
