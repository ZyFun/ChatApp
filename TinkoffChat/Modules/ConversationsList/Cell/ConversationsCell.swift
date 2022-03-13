//
//  ConversationsCell.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 04.03.2022.
//

import UIKit

protocol ConversationsCellConfiguration: AnyObject {
    var name: String? {get set}
    var message: String? {get set}
    var date: Date? {get set}
    var online: Bool {get set}
    var hasUnreadMessages: Bool {get set}
}

final class ConversationsCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = ""
        lastMessageLabel.text = ""
        dateLabel.text = ""
        backgroundColor = .clear
        lastMessageLabel.font = .systemFont(ofSize: 15)
    }
}

// MARK: - Private methods
private extension ConversationsCell {
    func setupUI() {
        setupCell()
        setupProfileImage()
    }
    
    func setupCell() {
        accessoryType = .disclosureIndicator
    }
    
    func setupProfileImage() {
        profileImageView.backgroundColor = #colorLiteral(red: 0.8941176471, green: 0.9098039216, blue: 0.168627451, alpha: 1)
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
}

// MARK: - Protocol extension
extension ConversationsCellConfiguration {
    func configure(
        name: String?,
        message: String?,
        date: Date?,
        online: Bool,
        hasUnreadMessages: Bool
    ) {
        self.name = name
        self.message = message
        self.date = date
        self.online = online
        self.hasUnreadMessages = hasUnreadMessages
    }
}

// Мне кажется я сделал тут какую то фигню и можно как то по другому
// MARK: - Conversations Cell Configuration
extension ConversationsCell: ConversationsCellConfiguration {
    var name: String? {
        get {
            nil
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    var message: String? {
        get {
            nil
        }
        set {
            if newValue == nil {
                lastMessageLabel.text = "No messages yet"
                lastMessageLabel.font = .italicSystemFont(ofSize: 15)
            } else {
                lastMessageLabel.text = newValue
            }
        }
    }
    
    var date: Date? {
        get {
            nil
        }
        set {
            if let date = newValue {
                dateLabel.text = Date().toString(date: date)
            } else {
                dateLabel.text = ""
            }
        }
    }
    
    var online: Bool {
        get {
            false
        }
        set {
            if newValue {
                backgroundColor = #colorLiteral(red: 1, green: 1, blue: 0.7568627451, alpha: 1)
            }
        }
    }
    
    var hasUnreadMessages: Bool {
        get {
            false
        }
        set {
            if newValue {
                lastMessageLabel.font = .boldSystemFont(ofSize: 15)
            }
        }
    }
}
