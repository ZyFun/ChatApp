//
//  ChannelDataSourceManager.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 16.04.2022.
//

import UIKit

protocol ChannelDataSourceManagerProtocol {
    var tableView: UITableView { get set }
    var resultManager: ChannelFetchedResultsManagerProtocol { get set }
    var mySenderId: String? { get set }
}

final class ChannelDataSourceManager: NSObject, ChannelDataSourceManagerProtocol {
    let imageLoadingManager: ImageLoadingManagerProtocol
    var tableView: UITableView
    var resultManager: ChannelFetchedResultsManagerProtocol
    var mySenderId: String?
    
    // MARK: - Initializer
    
    init(
        resultManager: ChannelFetchedResultsManagerProtocol,
        tableView: UITableView
    ) {
        imageLoadingManager = ImageLoadingManager()
        self.resultManager = resultManager
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
    }
}

// MARK: - Table view data source

extension ChannelDataSourceManager: UITableViewDataSource {
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
            withIdentifier: MessageCell.identifier,
            for: indexPath
        ) as? MessageCell else { return UITableViewCell() }
        
        let message = resultManager.fetchedResultsController.object(at: indexPath) as? DBMessage
        
        var isImage = false
        if let message = message?.content {
            if message.contains("http") {
                isImage.toggle()
            }
        }
        
        cell.configureMessageCell(
            senderName: message?.senderName,
            isImage: isImage,
            textMessage: message?.content ?? "",
            dateCreated: message?.created ?? Date(),
            isIncoming: message?.senderId != mySenderId
        )
        
        return cell
    }
}
