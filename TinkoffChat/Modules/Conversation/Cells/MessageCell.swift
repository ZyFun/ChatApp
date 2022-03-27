//
//  MessageCell.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 07.03.2022.
//

import UIKit

protocol MessageCellConfiguration: AnyObject {
    var senderName: String? { get set }
    var textMessage: String? { get set }
    var dateCreated: Date { get set }
}

final class MessageCell: UITableViewCell {
    enum Identifier: String {
        case incoming = "incomingMessage"
        case outgoing = "outgoingMessage"
    }
    
    enum NibName: String {
        case incoming = "IncomingMessageCell"
        case outgoing = "OutgoingMessageCell"
    }
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var textMessageLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
}

extension MessageCell: MessageCellConfiguration {
    var senderName: String? {
        get {
            nil
        }
        set {
            senderNameLabel.text = newValue
        }
    }
    
    var textMessage: String? {
        get {
            nil
        }
        set {
            textMessageLabel.text = newValue
        }
    }
    
    var dateCreated: Date {
        get {
            Date()
        }
        set {
            dateCreatedLabel.text = Date().toString(date: newValue)
        }
    }
}

private extension MessageCell {
    func setupUI() {
        selectionStyle = .none
        messageView.layer.cornerRadius = 8
        
        senderNameLabel.font = .boldSystemFont(ofSize: 16)
        
        dateCreatedLabel.font = .systemFont(ofSize: 11)
        
        setupTheme()
    }
    
    func setupTheme() {
        changePrototypeColorCells()
        backgroundColor = .clear
        textMessageLabel.textColor = .appColorLoadFor(.text)
        senderNameLabel.textColor = .appColorLoadFor(.senderName)
        dateCreatedLabel.textColor = .appColorLoadFor(.dateCreated)
    }
    
    func changePrototypeColorCells() {
        if reuseIdentifier == MessageCell.Identifier.incoming.rawValue {
            messageView.backgroundColor = .appColorLoadFor(.leftMessage)
        } else {
            messageView.backgroundColor = .appColorLoadFor(.rightMessage)
        }
    }
}

// MARK: - Protocol extension

extension MessageCellConfiguration {
    func configure(
        senderName: String?,
        textMessage: String,
        dateCreated: Date
    ) {
        self.senderName = senderName
        self.textMessage = textMessage
        self.dateCreated = dateCreated
    }
}
