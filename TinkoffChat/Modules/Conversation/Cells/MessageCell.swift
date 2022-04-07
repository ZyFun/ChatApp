//
//  MessageCell.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 07.04.2022.
//

import UIKit

struct MessageCellConfiguration {
    var senderName: String?
    var textMessage: String?
    var dateCreated: Date
}

class MessageCell: UITableViewCell {
    static let identifier = String(describing: MessageCell.self)
    
    private let viewContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let senderNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appColorLoadFor(.senderName)
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private let textMessageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appColorLoadFor(.text)
        label.numberOfLines = 0
        return label
    }()
    
    private let dateCreatedLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appColorLoadFor(.dateCreated)
        label.font = .systemFont(ofSize: 11)
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        viewContainer.translatesAutoresizingMaskIntoConstraints = false
        senderNameLabel.translatesAutoresizingMaskIntoConstraints = false
        textMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        dateCreatedLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(viewContainer)
        viewContainer.addSubview(senderNameLabel)
        viewContainer.addSubview(textMessageLabel)
        viewContainer.addSubview(dateCreatedLabel)
        
        NSLayoutConstraint.activate([
            viewContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 11),
//            viewContainer.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width * 2/3),
            viewContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -11),
            
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
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var incomingMessageConstraint = [
        viewContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 11),
        viewContainer.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -90)
    ]
    
    private lazy var outgoingMessageConstraint = [
        viewContainer.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 90),
        viewContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -11)
    ]
    
    private func setupIncomingMessageConstraint() {
        incomingMessageConstraint.forEach({ $0.isActive = true })
        outgoingMessageConstraint.forEach({ $0.isActive = false })
        viewContainer.backgroundColor = .appColorLoadFor(.leftMessage)
    }
    
    private func setupOutgoingMessageConstraint() {
        incomingMessageConstraint.forEach({ $0.isActive = false })
        outgoingMessageConstraint.forEach({ $0.isActive = true })
        viewContainer.backgroundColor = .appColorLoadFor(.rightMessage)
    }
    
    private func setConfigure() {
        
    }
    
}

// MARK: - Public methods

extension MessageCell {
    func configureIncomingMessage(
        senderName: String?,
        textMessage: String,
        dateCreated: Date
    ) {
        let configureModel = MessageCellConfiguration(
            senderName: senderName,
            textMessage: textMessage,
            dateCreated: dateCreated
        )
        
        senderNameLabel.text = configureModel.senderName
        textMessageLabel.text = configureModel.textMessage
        dateCreatedLabel.text = Date().toString(date: configureModel.dateCreated)
        setupIncomingMessageConstraint()
    }
    
    func configureOutgoingMessage(
        senderName: String?,
        textMessage: String,
        dateCreated: Date
    ) {
        let configureModel = MessageCellConfiguration(
            senderName: nil,
            textMessage: textMessage,
            dateCreated: dateCreated
        )
        
        senderNameLabel.text = configureModel.senderName
        textMessageLabel.text = configureModel.textMessage
        dateCreatedLabel.text = Date().toString(date: configureModel.dateCreated)
        setupOutgoingMessageConstraint()
        setConfigure()
    }
}
