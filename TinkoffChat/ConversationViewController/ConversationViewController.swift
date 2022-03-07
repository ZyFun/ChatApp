//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 07.03.2022.
//

import UIKit

class ConversationViewController: UIViewController {
    
    var conversationNameTitle: String?
    
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
        // TODO: Удалить после прекращения поддержки iOS ниже 15
        // Используется для скрытия лишних разделителей в таблице
        // при использовании iOS ниже 15
        conversationTableView.tableFooterView = UIView()
        setupXibs()
    }
    
    /// Инициализация Xibs
    func setupXibs() {
        
    }
}
