//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 07.03.2022.
//

import UIKit

final class ConversationViewController: UIViewController {
    
    var conversationNameTitle: String?
    
    private let messages = Messages.getMessages()
    
    @IBOutlet weak var conversationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

private extension ConversationViewController {
    func setup() {
        setupNavigationBar()
        setupTableView()
    }
    
    func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        title = conversationNameTitle
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
        
        if message.isIncoming {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MessageCell.Identifier.incoming.rawValue,
                for: indexPath
            ) as? MessageCell else { return UITableViewCell() }
            
            cell.textMessage = message.text
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MessageCell.Identifier.outgoing.rawValue,
                for: indexPath
            ) as? MessageCell else { return UITableViewCell() }
            
            cell.textMessageLabel.text = message.text
            
            return cell
        }
    }
}
