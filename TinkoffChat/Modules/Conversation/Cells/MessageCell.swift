//
//  MessageCell.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 07.04.2022.
//

import UIKit

class MessageCell: UITableViewCell {
    static let identifier = String(describing: MessageCell.self)
    
    // MARK: - Private properties
    
    private var leadingConstraintViewContainer = NSLayoutConstraint()
    private var trailingConstraintViewContainer = NSLayoutConstraint()
    
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
    
    // MARK: - Init
    
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
            viewContainer.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width * 2 / 3),
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
        
        leadingConstraintViewContainer = viewContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 11)
        leadingConstraintViewContainer.isActive = true
        
        trailingConstraintViewContainer = viewContainer.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -11)
        trailingConstraintViewContainer.isActive = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupIncomingOrOutgoingMessageConstraint(incoming: Bool) {
        if incoming {
            leadingConstraintViewContainer.isActive = true
            trailingConstraintViewContainer.isActive = false
            viewContainer.backgroundColor = .appColorLoadFor(.leftMessage)
        } else {
            leadingConstraintViewContainer.isActive = false
            trailingConstraintViewContainer.isActive = true
            senderNameLabel.text = nil
            viewContainer.backgroundColor = .appColorLoadFor(.rightMessage)
        }
    }
}

// MARK: - Public methods

extension MessageCell {
    func configureMessageCell(
        senderName: String?,
        textMessage: String,
        dateCreated: Date,
        isIncoming: Bool
    ) {
        senderNameLabel.text = senderName
        textMessageLabel.text = textMessage
        dateCreatedLabel.text = Date().toString(date: dateCreated)
        setupIncomingOrOutgoingMessageConstraint(incoming: isIncoming)
    }
}
