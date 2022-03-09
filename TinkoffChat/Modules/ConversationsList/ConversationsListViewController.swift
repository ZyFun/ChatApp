//
//  ConversationsListViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 04.03.2022.
//

import UIKit

final class ConversationsListViewController: UITableViewController {
    
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
        
        guard let cell = tableView.dequeueReusableCell(
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
    
    // MARK: - Table view delegate
    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        90
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let conversationVC = ConversationViewController(
            nibName: String(describing: ConversationViewController.self),
            bundle: nil
        )
        
        let conversation = indexPath.section == 0
        ? onlineConversations[indexPath.row]
        : historyConversations[indexPath.row]
        
        conversationVC.conversationNameTitle = conversation.name
        
        navigationController?.pushViewController(
            conversationVC,
            animated: true
        )
    }
}

extension ConversationsListViewController {
    func setup() {
        setupNavigationBar()
        setupTableView()
    }
    
    func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Tinkoff Chat"
        
        setupNavBarButtons()
    }
    
    func setupNavBarButtons() {
        let profileButton = UILabel(
            frame: CGRect(x: 0, y: 0, width: 40, height: 40)
        )
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(profileButtonPressed)
        )
        
        profileButton.text = "UN" // TODO: Сделать выбор букв из имени и фамилии
        profileButton.textAlignment = .center
        profileButton.backgroundColor = #colorLiteral(red: 0.8941176471, green: 0.9098039216, blue: 0.168627451, alpha: 1)
        profileButton.layer.cornerRadius = profileButton.frame.height / 2
        profileButton.layer.masksToBounds = true
        
        profileButton.isUserInteractionEnabled = true
        profileButton.addGestureRecognizer(tapGesture)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: profileButton
        )
    }
    
    @objc func profileButtonPressed() {
        
         guard let myProfileVC = UIStoryboard(
            name: String(describing: MyProfileViewController.self),
            bundle: nil
         ).instantiateInitialViewController() else { return }
        
        present(myProfileVC, animated: true)
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
