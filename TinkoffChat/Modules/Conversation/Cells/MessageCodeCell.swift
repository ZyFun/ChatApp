//
//  MessageCodeCell.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 06.04.2022.
//

import UIKit

protocol MessageCellConfiguration: AnyObject {
    var senderName: String? { get set }
    var textMessage: String? { get set }
    var dateCreated: Date { get set }
    var isIncoming: Bool? { get set }
}

class MessageCodeCell: UITableViewCell {
    static let identifier = String(describing: MessageCodeCell.self)
    
    let viewContainer = UIView()
    
    let senderNameLabel = UILabel()
    let textMessageLabel = UILabel()
    let dateCreatedLabel = UILabel()
    
    // этот параметр вызвал для теста, чтобы точно знать что приходит только true или false
    var incoming: Bool! {
        didSet {
            setupIncomingOrOutgoingMessageConstraints(isIncoming: incoming)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

extension MessageCodeCell: MessageCellConfiguration {
    var senderName: String? {
        get {
            senderNameLabel.text
        }
        set {
            senderNameLabel.text = newValue
        }
    }
    
    var textMessage: String? {
        get {
            textMessageLabel.text
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
    
    var isIncoming: Bool? {
        get {
            nil
        }
        set {
            guard let newValue = newValue else { return }
            
            if newValue {
                senderNameLabel.isHidden = false
                viewContainer.backgroundColor = .appColorLoadFor(.leftMessage)
            } else {
                senderNameLabel.text = nil
                viewContainer.backgroundColor = .appColorLoadFor(.rightMessage)
            }
        }
    }
}

private extension MessageCodeCell {
    func setupUI() {
        setupInterface()
        setupViews()
        setupLabels()
    }
    
    func setupInterface() {
        addSubview(viewContainer)
        viewContainer.addSubview(senderNameLabel)
        viewContainer.addSubview(textMessageLabel)
        viewContainer.addSubview(dateCreatedLabel)
        
        viewContainer.translatesAutoresizingMaskIntoConstraints = false
        senderNameLabel.translatesAutoresizingMaskIntoConstraints = false
        textMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        dateCreatedLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        
//        messageConstraint.forEach({ $0.isActive })
//
//        NSLayoutConstraint.activate(messageConstraint)
        
    }
    
    func setupIncomingOrOutgoingMessageConstraints(isIncoming: Bool) {
        let incomingConstraint = [
            viewContainer.topAnchor.constraint(equalTo: topAnchor, constant: 11),
            viewContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 11),
            viewContainer.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width * 2/3),
            viewContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11),
            
            senderNameLabel.topAnchor.constraint(equalTo: viewContainer.topAnchor, constant: 8),
            senderNameLabel.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 8),
            senderNameLabel.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: -8),
            senderNameLabel.bottomAnchor.constraint(equalTo: textMessageLabel.topAnchor, constant: -3),
            
            textMessageLabel.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 8),
            textMessageLabel.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: -8),
            
            dateCreatedLabel.topAnchor.constraint(equalTo: textMessageLabel.bottomAnchor, constant: 7),
            dateCreatedLabel.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 8),
            dateCreatedLabel.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: -8),
            dateCreatedLabel.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor, constant: -6)
        ]
        
        let outgoingConstraint = [
            viewContainer.topAnchor.constraint(equalTo: topAnchor, constant: 11),
            viewContainer.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width * 2/3),
            viewContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -11),
            viewContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11),
            
            senderNameLabel.topAnchor.constraint(equalTo: viewContainer.topAnchor, constant: 8),
            senderNameLabel.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 8),
            senderNameLabel.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: -8),
            senderNameLabel.bottomAnchor.constraint(equalTo: textMessageLabel.topAnchor, constant: -3),
            
            textMessageLabel.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 8),
            textMessageLabel.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: -8),
            
            dateCreatedLabel.topAnchor.constraint(equalTo: textMessageLabel.bottomAnchor, constant: 7),
            dateCreatedLabel.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 8),
            dateCreatedLabel.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: -8),
            dateCreatedLabel.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor, constant: -6)
        ]
        
        if isIncoming {
            incomingConstraint.forEach({ $0.isActive = true })
            outgoingConstraint.forEach({ $0.isActive = false })
        } else {
            incomingConstraint.forEach({ $0.isActive = false })
            outgoingConstraint.forEach({ $0.isActive = true })
        }
    }
    
    func setupLabels() {
        senderNameLabel.font = .boldSystemFont(ofSize: 16)
        senderNameLabel.numberOfLines = 0
        senderNameLabel.textColor = .appColorLoadFor(.senderName)
        
        textMessageLabel.numberOfLines = 0
        textMessageLabel.textColor = .appColorLoadFor(.text)
        
        dateCreatedLabel.font = .systemFont(ofSize: 11)
        dateCreatedLabel.textAlignment = .right
        dateCreatedLabel.textColor = .appColorLoadFor(.dateCreated)
    }
    
    func setupViews() {
        backgroundColor = .clear
        
        selectionStyle = .none
        
        viewContainer.layer.cornerRadius = 8
    }
}

// MARK: - Protocol extension

extension MessageCellConfiguration {
    func configure(
        senderName: String?,
        textMessage: String,
        dateCreated: Date,
        isIncoming: Bool
    ) {
        self.senderName = senderName
        self.textMessage = textMessage
        self.dateCreated = dateCreated
        self.isIncoming = isIncoming
    }
}
