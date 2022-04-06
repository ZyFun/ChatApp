//
//  Test.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 06.04.2022.
//

import UIKit

class Test: UITableViewCell {

    // MARK: - Private UI properties
    
    private let speechBubbleView = UIView()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
//        label.font = UIFont(name: "SFProText-Regular", size: 16)
        label.textAlignment = .left
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
//        label.font = UIFont(name: "SFProText-Regular", size: 16)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
//        label.font = UIFont(name: "SFProText-Regular", size: 11)
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        speechBubbleView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(speechBubbleView)
        contentView.addSubview(messageLabel)
        contentView.addSubview(dateLabel)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private layout properties
    
    private let messageLabelWidth = UIScreen.main.bounds.width * 3 / 4 - 26
    
    private lazy var incomingConstraints = [
        speechBubbleView.widthAnchor.constraint(equalTo: messageLabel.widthAnchor, constant: 26),
        speechBubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
        speechBubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
        speechBubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

        nameLabel.topAnchor.constraint(equalTo: speechBubbleView.topAnchor, constant: 5),
        nameLabel.leadingAnchor.constraint(equalTo: speechBubbleView.leadingAnchor, constant: 16),
        nameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: messageLabelWidth),

        messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: messageLabelWidth),
        messageLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 35),
        messageLabel.widthAnchor.constraint(greaterThanOrEqualTo: nameLabel.widthAnchor),
        messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),
        messageLabel.leadingAnchor.constraint(equalTo: speechBubbleView.leadingAnchor, constant: 16),
        messageLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -3),

        dateLabel.trailingAnchor.constraint(equalTo: speechBubbleView.trailingAnchor, constant: -10),
        dateLabel.bottomAnchor.constraint(equalTo: speechBubbleView.bottomAnchor, constant: -3)
    ]

    private lazy var outdoingConstraints = [
        speechBubbleView.widthAnchor.constraint(equalTo: messageLabel.widthAnchor, constant: 30),
        speechBubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
        speechBubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        speechBubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

        messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: messageLabelWidth),
        messageLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 35),
        messageLabel.topAnchor.constraint(equalTo: speechBubbleView.topAnchor, constant: 5),
        messageLabel.leadingAnchor.constraint(equalTo: speechBubbleView.leadingAnchor, constant: 16),
        messageLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -3),

        dateLabel.trailingAnchor.constraint(equalTo: speechBubbleView.trailingAnchor, constant: -15),
        dateLabel.bottomAnchor.constraint(equalTo: speechBubbleView.bottomAnchor, constant: -3)
    ]
    
    // MARK: - Private methods
    
    private func setupIncomingMessageConstraints() {
        contentView.addSubview(nameLabel)
        outdoingConstraints.forEach { $0.isActive = false }
        incomingConstraints.forEach { $0.isActive = true }
        speechBubbleView.backgroundColor = .blue
    }
    
    private func setupOutdoingMessageConstraints() {
        nameLabel.removeFromSuperview()
        incomingConstraints.forEach { $0.isActive = false }
        outdoingConstraints.forEach { $0.isActive = true }
        speechBubbleView.backgroundColor = .green
    }
    
}

// MARK: - Public methods

extension Test {
    
    func setIncomingMessage(messageText: String, date: String, name: String) {
        nameLabel.text = name
        messageLabel.text = messageText
        dateLabel.text = date
        setupIncomingMessageConstraints()
    }
    
    func setOutdoingMessage(messageText: String, date: String) {
        messageLabel.text = messageText
        dateLabel.text = date
        setupOutdoingMessageConstraints()
    }

}
