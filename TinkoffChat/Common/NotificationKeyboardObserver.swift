//
//  NotificationKeyboardObserver.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 29.03.2022.
//

import UIKit

class NotificationKeyboardObserver {
    
    /// Constraint, который будет изменять размер в соответствии с размером клавиатуры
    /// при её вызове.
    var constraint: NSLayoutConstraint?
    
    deinit {
        removeKeyboardNotifications()
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardFrameSize = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
        if let constraint = constraint {
            constraint.constant = keyboardFrameSize?.height ?? 0
        }
        
    }
    
    @objc private func keyboardWillHide() {
        if let constraint = constraint {
            constraint.constant = .zero
        }
    }
}
