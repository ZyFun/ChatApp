//
//  MessageCell.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 07.03.2022.
//

import UIKit

protocol MessageCellConfiguration: AnyObject {
    var textMessage: String? { get set }
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
    
    @IBOutlet weak var textMessageLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
}

extension MessageCell: MessageCellConfiguration {
    var textMessage: String? {
        get {
            nil
        }
        set {
            textMessageLabel.text = newValue
        }
    }
}

private extension MessageCell {
    func setupUI() {
        selectionStyle = .none
        messageView.layer.cornerRadius = 8
        setupTheme()
    }
    
    func setupTheme() {
        changePrototypeColorCells()
        backgroundColor = .clear
        textMessageLabel.textColor = .appColorLoadFor(.text)
    }
    
    func changePrototypeColorCells() {
        if reuseIdentifier == MessageCell.Identifier.incoming.rawValue {
            messageView.backgroundColor = .appColorLoadFor(.leftMessage)
        } else {
            messageView.backgroundColor = .appColorLoadFor(.rightMessage)
        }
    }
    
}
