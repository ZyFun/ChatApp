//
//  IncomingMessageCell.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 07.03.2022.
//

import UIKit

protocol MessageCellConfiguration: AnyObject {
    var textMessage: String? { get set } // В задании указано свойство text, но его невозможно использовать в этом классе, так-как есть такое deprecated поле у класса ячейки.
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
        changePrototypeColorCells()
    }
    
    func changePrototypeColorCells() {
        if reuseIdentifier == MessageCell.Identifier.incoming.rawValue {
            messageView.backgroundColor = #colorLiteral(red: 0.8745098039, green: 0.8745098039, blue: 0.8745098039, alpha: 1)
        } else {
            messageView.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.968627451, blue: 0.7725490196, alpha: 1)
        }
    }
    
}
