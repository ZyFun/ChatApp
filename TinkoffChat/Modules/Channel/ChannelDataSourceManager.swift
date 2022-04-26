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
    var tableView: UITableView
    var resultManager: ChannelFetchedResultsManagerProtocol
    var mySenderId: String?
    
    // MARK: - Initializer
    
    init(
        resultManager: ChannelFetchedResultsManagerProtocol,
        tableView: UITableView
    ) {
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
        
        // TODO: ([26.04.2022]) Тестовый вариант кода. Сделать методом и перенести в слой менеджера
        let photoImageVC = PhotoImageView(image: nil)
        var image: UIImage?
        
        if let message = message?.content {
            if message.contains("http") {
                let  messageComponents = message.components(separatedBy: " ")
                for component in messageComponents {
                    if component.contains("http") {
                        image = photoImageVC.selectImageToSetInProfile(urlString: component)
                    }
                }
            }
        } else {
            print("Ничего нет")
        }
        
        cell.configureMessageCell(
            senderName: message?.senderName,
            imageMessage: image, // TODO: ([26.04.2022]) скорее всего нужно будет не передавать сюда, а грузить уже в поцессе
            // или передавать значение тру и отображать плейсхолдер с загрузкой
            textMessage: message?.content ?? "",
            dateCreated: message?.created ?? Date(),
            isIncoming: message?.senderId != mySenderId
        )
        
        return cell
    }
}
