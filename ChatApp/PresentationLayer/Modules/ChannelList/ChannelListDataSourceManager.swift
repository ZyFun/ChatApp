//
//  ChannelListDataSourceManager.swift
//  ChatApp
//
//  Created by Дмитрий Данилин on 17.04.2022.
//

import UIKit

protocol ChannelListDataSourceManagerProtocol {
    var resultManager: ChannelListFetchedResultsManagerProtocol { get set }
    var channelListViewControllerDelegate: ChannelListViewControllerDelegate? { get set }
}

final class ChannelListDataSourceManager: NSObject, ChannelListDataSourceManagerProtocol {
    private let channelListService: ChannelListServiceProtocol
    var resultManager: ChannelListFetchedResultsManagerProtocol
    
    weak var channelListViewControllerDelegate: ChannelListViewControllerDelegate?
    
    // MARK: - Initializer
    
    init (
        resultManager: ChannelListFetchedResultsManagerProtocol,
        channelListService: ChannelListServiceProtocol
    ) {
        self.resultManager = resultManager
        self.channelListService = channelListService
    }
}

// MARK: - Table view data source

extension ChannelListDataSourceManager: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        if let sections = resultManager.fetchedResultsController.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ChannelCell.self),
            for: indexPath
        ) as? ChannelCell else { return UITableViewCell() }
        
        guard let channel = resultManager.fetchedResultsController.object(at: indexPath) as? DBChannel else {
            Logger.error("Ошибка каста object к DBChannel")
            return UITableViewCell()
        }
        
        cell.configure(
            name: channel.name,
            message: channel.lastMessage,
            date: channel.lastActivity,
            online: false,
            hasUnreadMessages: false
        )
        
        return cell
    }
}

// MARK: - Table view delegate

extension ChannelListDataSourceManager: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        90
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        channelListViewControllerDelegate?.pushChannelVC(with: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            guard let channel = resultManager.fetchedResultsController.object(at: indexPath) as? DBChannel else {
                Logger.error("Ошибка каста object до DBChannel при удалении ячейки")
                return
            }
            
            channelListService.deleteFromFirebase(channel)
        }
    }
}
