//
//  FetchResultManager.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 14.04.2022.
//

import UIKit
import CoreData

final class ChannelFetchedResultsManager: NSObject, NSFetchedResultsControllerDelegate {
    var tableView: UITableView
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    var mySenderId: String?
    
    init(
        mySenderId: String?,
        tableView: UITableView,
        fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        self.tableView = tableView
        self.fetchedResultsController = fetchedResultsController
        self.mySenderId = mySenderId
        
        super.init()
        self.fetchedResultsController.delegate = self
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
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
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }

            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                let message = fetchedResultsController.object(at: indexPath) as? DBMessage
                let cell = tableView.cellForRow(at: indexPath) as? MessageCell
                
                cell?.configureMessageCell(
                    senderName: message?.senderName,
                    textMessage: message?.content ?? "",
                    dateCreated: message?.created ?? Date(),
                    isIncoming: message?.senderId != mySenderId
                )
            }
        @unknown default:
            Logger.error("Что то пошло не так в NSFetchedResultsControllerDelegate")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
