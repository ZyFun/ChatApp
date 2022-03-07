//
//  IncomingMessageCell.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 07.03.2022.
//

import UIKit

class MessageCell: UITableViewCell {
    static let incomingIdentifier = "incomingMessage"
    static let outgoingIdentifier = "outgoingMessage"
    
    static let nibNameIncomingCell = "IncomingMessageCell"
    static let nibNameOutgoingCell = "OutgoingMessageCell"
    
    @IBOutlet weak var textMessageLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        messageView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
