//
//  ConversationsListViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 04.03.2022.
//

import UIKit

class ConversationsListViewController: UITableViewController {
    
    private let conversations = Conversation.getConversations()
    private var onlineConversations: [Conversation] = []
    private var historyConversations: [Conversation] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        sortingConversationSections()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        section == 0 ? onlineConversations.count : historyConversations.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        section == 0 ? "Online" : "History"
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard var cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ConversationsCell.self),
            for: indexPath
        ) as? ConversationsCell else { return UITableViewCell() }
        
        let conversation = indexPath.section == 0
        ? onlineConversations[indexPath.row]
        : historyConversations[indexPath.row]

        cell.configure(
            name: conversation.name,
            message: conversation.message,
            date: conversation.date,
            online: conversation.online,
            hasUnreadMessages: conversation.hasUnreadMessages
        )

        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        90
    }
}

extension ConversationsListViewController {
    func setup() {
        setupNavigationBar()
        setupTableView()
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Tinkoff Chat"
    }
    
    func setupTableView() {
        setupXibs()
    }
    
    /// Инициализация Xibs
    func setupXibs() {
        tableView.register(
            UINib(
                nibName: String(describing: ConversationsCell.self),
                bundle: nil
            ),
            forCellReuseIdentifier: String(describing: ConversationsCell.self)
        )
    }
    
    func sortingConversationSections() {
        for conversation in conversations {
            
            if conversation.online {
                onlineConversations.append(conversation)
            } else if conversation.message != nil {
                historyConversations.append(conversation)
            }
        }
    }
}
