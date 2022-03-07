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
                nibName: String(describing: IncomingMessageCell.self),
                bundle: nil
            ),
            forCellReuseIdentifier: String(
                describing: IncomingMessageCell.self
            )
        )
    }
}

// MARK: - Table view data source
extension ConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: IncomingMessageCell.self),
            for: indexPath
        ) as? IncomingMessageCell else { return UITableViewCell() }
        
        cell.textMessageLabel.text = messages[indexPath.row].message
    
        return cell
    }
}

// MARK: - Table view delegate
extension ConversationViewController: UITableViewDelegate {
    
}
