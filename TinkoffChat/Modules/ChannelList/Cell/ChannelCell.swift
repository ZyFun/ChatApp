//
//  ChannelCell.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 04.03.2022.
//

import UIKit

protocol ChannelCellConfiguration: AnyObject {
    var name: String? {get set}
    var message: String? {get set}
    var date: Date? {get set}
    var online: Bool {get set}
    var hasUnreadMessages: Bool {get set}
}

final class ChannelCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setupTheme()
        nameLabel.text = ""
        lastMessageLabel.text = ""
        dateLabel.text = ""
        backgroundColor = .clear
        lastMessageLabel.font = .systemFont(ofSize: 15)
    }
}

// MARK: - Private methods
private extension ChannelCell {
    func setupUI() {
        setupTheme()
        setupCell()
        setupProfileImage()
    }
    
    func setupCell() {
        accessoryType = .disclosureIndicator
    }
    
    func setupProfileImage() {
        profileImageView.backgroundColor = .appColorLoadFor(.profileImageView)
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
    
    func setupTheme() {
        nameLabel.textColor = .appColorLoadFor(.text)
        profileImageLabel.textColor = .appColorLoadFor(.textImageView)
    }
}

// MARK: - Protocol extension
extension ChannelCellConfiguration {
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
// MARK: - Channel Cell Configuration
extension ChannelCell: ChannelCellConfiguration {
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
                backgroundColor = .appColorLoadFor(.online)
            } else {
                backgroundColor = .clear
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
