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
    private var themeManager: ThemeManagerProtocol
    
    private let viewContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let senderNameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private let textMessageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private let dateCreatedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textAlignment = .right
        return label
    }()
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.themeManager = ThemeManager.shared
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        
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
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupIncomingOrOutgoingMessageConstraint(incoming: Bool) {
        if incoming {
            leadingConstraintViewContainer.isActive = true
            trailingConstraintViewContainer.isActive = false
            viewContainer.backgroundColor = themeManager.appColorLoadFor(.leftMessage)
        } else {
            leadingConstraintViewContainer.isActive = false
            trailingConstraintViewContainer.isActive = true
            senderNameLabel.text = nil
            viewContainer.backgroundColor = themeManager.appColorLoadFor(.rightMessage)
        }
    }
    
    func setupUI() {
        contentView.backgroundColor = themeManager.appColorLoadFor(.backgroundView)
        senderNameLabel.textColor = themeManager.appColorLoadFor(.senderName)
        textMessageLabel.textColor = themeManager.appColorLoadFor(.text)
        dateCreatedLabel.textColor = themeManager.appColorLoadFor(.dateCreated)
        
        // Развернул отображение ячейки, так как таблицу я тоже развернул,
        // чтобы первая ячейка была снизу.
        contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
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
