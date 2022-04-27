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
        
        // TODO: ([26.04.2022]) Тестовый вариант кода. Сделать методом и перенести в слой менеджера
        var image: UIImage?
        // Используется для отображения ошибки, если со ссылкой сто-то не так
        var textMessage = message?.content
        
        if let message = message?.content {
            if message.contains("http") {
                let  messageComponents = message.components(separatedBy: " ")
                for component in messageComponents where component.contains("http") {
                    imageLoadingManager.getImage(from: component) { result in
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
        } else {
            print("Ничего нет")
        }
        
        cell.configureMessageCell(
            senderName: message?.senderName,
            imageMessage: image, // TODO: ([26.04.2022]) скорее всего нужно будет не передавать сюда, а грузить уже в поцессе
            // или передавать значение тру и отображать плейсхолдер с загрузкой
            textMessage: textMessage ?? "",
            dateCreated: message?.created ?? Date(),
            isIncoming: message?.senderId != mySenderId
        )
        
        return cell
    }
}
