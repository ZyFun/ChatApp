//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 07.03.2022.
//

import UIKit

final class ConversationViewController: UIViewController {
    
    // MARK: - Public properties
    
    var channelTitle: String?
    var channelID: String = ""
    var messages: [Message] = []
    let mySenderId: String = "ZyFun"
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var conversationTableView: UITableView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        loadMessages()
    }
}

// MARK: - Private methods

private extension ConversationViewController {
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
        conversationTableView.dataSource = self
        
        conversationTableView.separatorStyle = .none
        
        setupXibs()
    }
    
    /// Инициализация Xibs
    func setupXibs() {
        conversationTableView.register(
            UINib(
                nibName: MessageCell.NibName.incoming.rawValue,
                bundle: nil
            ),
            forCellReuseIdentifier: String(
                describing: MessageCell.Identifier.incoming.rawValue
            )
        )
        
        conversationTableView.register(
            UINib(
                nibName: MessageCell.NibName.outgoing.rawValue,
                bundle: nil
            ),
            forCellReuseIdentifier: MessageCell.Identifier.outgoing.rawValue
        )
    }
    
    func setupTheme() {
        conversationTableView.backgroundColor = .appColorLoadFor(.backgroundView)
    }
    
    func loadMessages() {
        FirestoreService.shared.fetchMessages(
            channelID: channelID
        ) { [weak self] result in
            
            switch result {
            case .success(let messages):
                self?.messages = messages
                // TODO: ([27.03.2022]) Посмотреть где оптимальнее делать сортировку
                self?.messages.sort(by: { $0.created > $1.created })
                self?.conversationTableView.reloadData()
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

extension ConversationViewController: UITableViewDataSource {
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
        
        // TODO: ([27.03.2022)] Это всё можно сделать одним методом, нужно присвоить идентификатор в зависимости от того, какая нужна ячейка
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
                senderName: message.senderName,
                textMessage: message.content,
                dateCreated: message.created
            )
            
            return cell
        }
    }
}
