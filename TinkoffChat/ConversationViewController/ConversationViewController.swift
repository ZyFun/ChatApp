//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 07.03.2022.
//

import UIKit

class ConversationViewController: UIViewController {
    
    var conversationNameTitle: String?
    
    private let messages = Messages.getMessages()
    
    @IBOutlet weak var conversationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

extension ConversationViewController {
    func setup() {
        setupNavigationBar()
        setupTableView()
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        title = conversationNameTitle
    }
    
    func setupTableView() {
        conversationTableView.delegate = self
        conversationTableView.dataSource = self
        
        conversationTableView.separatorStyle = .none
        
        setupXibs()
    }
    
    /// Инициализация Xibs
    func setupXibs() {
        conversationTableView.register(
            UINib(
                nibName: MessageCell.nibNameIncomingCell,
                bundle: nil
            ),
            forCellReuseIdentifier: String(
                describing: MessageCell.incomingIdentifier
            )
        )
        
        conversationTableView.register(
            UINib(
                nibName: MessageCell.nibNameOutgoingCell,
                bundle: nil
            ),
            forCellReuseIdentifier: MessageCell.outgoingIdentifier
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
                withIdentifier: MessageCell.incomingIdentifier,
                for: indexPath
            ) as? MessageCell else { return UITableViewCell() }
            
            cell.messageView.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.968627451, blue: 0.7725490196, alpha: 1)
            cell.textMessageLabel.text = message.text
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MessageCell.outgoingIdentifier,
                for: indexPath
            ) as? MessageCell else { return UITableViewCell() }
            
            cell.messageView.backgroundColor = #colorLiteral(red: 0.8745098039, green: 0.8745098039, blue: 0.8745098039, alpha: 1)
            cell.textMessageLabel.text = message.text
            
            return cell
        }
    }
}

// MARK: - Table view delegate
extension ConversationViewController: UITableViewDelegate {
    
}
