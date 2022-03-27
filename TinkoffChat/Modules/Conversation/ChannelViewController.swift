//
//  ChannelViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 07.03.2022.
//

import UIKit

final class ChannelViewController: UIViewController {
    
    // MARK: - Public properties
    
    var channelTitle: String?
    var channelID: String = ""
    var messages: [Message] = []
    let mySenderId: String = "ZyFun"
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var channelTableView: UITableView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        loadMessages()
    }
}

// MARK: - Private methods

private extension ChannelViewController {
    func setup() {
        setupNavigationBar()
        setupTableView()
        setupTheme()
    }
    
    func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        title = channelTitle
    }
    
    func setupTableView() {
        channelTableView.dataSource = self
        
        channelTableView.separatorStyle = .none
        
        setupXibs()
    }
    
    func scrollCellsToBottom() {
        if !messages.isEmpty {
            let lastRow = channelTableView.numberOfRows(inSection: 0) - 1
            let indexPath = IndexPath(row: lastRow, section: 0)
            channelTableView.scrollToRow(
                at: indexPath,
                at: .top,
                animated: false
            )
        }
    }
    
    /// Инициализация Xibs
    func setupXibs() {
        channelTableView.register(
            UINib(
                nibName: MessageCell.NibName.incoming.rawValue,
                bundle: nil
            ),
            forCellReuseIdentifier: String(
                describing: MessageCell.Identifier.incoming.rawValue
            )
        )
        
        channelTableView.register(
            UINib(
                nibName: MessageCell.NibName.outgoing.rawValue,
                bundle: nil
            ),
            forCellReuseIdentifier: MessageCell.Identifier.outgoing.rawValue
        )
    }
    
    func setupTheme() {
        channelTableView.backgroundColor = .appColorLoadFor(.backgroundView)
    }
    
    // MARK: - Firestore request
    
    // TODO: ([27.03.2022]) Добавить активити индикатор, пока грузятся сообщения.
    func loadMessages() {
        FirestoreService.shared.fetchMessages(
            channelID: channelID
        ) { [weak self] result in
            
            switch result {
            case .success(let messages):
                self?.messages = messages
                // TODO: ([27.03.2022]) Посмотреть где оптимальнее делать сортировку
                self?.messages.sort(by: { $0.created < $1.created })
                self?.channelTableView.reloadData()
                self?.scrollCellsToBottom()
            case .failure(let error):
                printDebug(error.localizedDescription)
            }
        }
    }
    
    // TODO: ([27.03.2022]) доделать метод отправки сообщения
    func sendMessage(channelID: String, senderID: String, message: String) {
        FirestoreService.shared.sendMessage(
            channelID: channelID,
            message: senderID,
            senderID: message
        )
    }
}

// MARK: - Table view data source

extension ChannelViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        messages.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        if message.senderId != mySenderId {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MessageCell.Identifier.incoming.rawValue,
                for: indexPath
            ) as? MessageCell else { return UITableViewCell() }

            cell.textMessage = message.content
            cell.configure(
                senderName: message.senderName,
                textMessage: message.content,
                dateCreated: message.created
            )
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MessageCell.Identifier.outgoing.rawValue,
                for: indexPath
            ) as? MessageCell else { return UITableViewCell() }

            cell.textMessage = message.content
            cell.configure(
                senderName: nil,
                textMessage: message.content,
                dateCreated: message.created
            )
            
            return cell
        }
    }
}
