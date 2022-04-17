//
//  ChannelListFetchedResultsManager.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 17.04.2022.
//

import UIKit
import CoreData

protocol ChannelListFetchedResultsManagerProtocol {
    var tableView: UITableView? { get set }
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> { get set }
    var isAppear: Bool { get set }
}

final class ChannelListFetchedResultsManager: NSObject, ChannelListFetchedResultsManagerProtocol {
    var tableView: UITableView?
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    var isAppear = true
    
    init(
        fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        self.fetchedResultsController = fetchedResultsController
        
        super.init()
        self.fetchedResultsController.delegate = self
    }
}

extension ChannelListFetchedResultsManager: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if isAppear {
            tableView?.beginUpdates()
        }
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        if isAppear {
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
                    let channel = fetchedResultsController.object(at: indexPath) as? DBChannel
                    let cell = tableView?.cellForRow(at: indexPath) as? ChannelCell
                    cell?.configure(
                        name: channel?.name,
                        message: channel?.lastMessage,
                        date: channel?.lastActivity,
                        online: false,
                        hasUnreadMessages: false
                    )
                }
            @unknown default:
                Logger.error("Что то пошло не так в NSFetchedResultsControllerDelegate")
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if isAppear {
            tableView?.endUpdates()
        }
    }
}
