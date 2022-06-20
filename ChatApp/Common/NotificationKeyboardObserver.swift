//
//  NotificationKeyboardObserver.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 29.03.2022.
//

import UIKit

protocol NotificationKeyboardObserverProtocol {
    func addChangeHeightObserver(
        for view: UIView,
        changeValueFor constraint: NSLayoutConstraint,
        with viewCase: NotificationKeyboardObserver.ViewCase
    )
}

class NotificationKeyboardObserver: NotificationKeyboardObserverProtocol {
    /// Перечисление для выбора текущего экрана, для правильного взаимодействия с констреинтами
    enum ViewCase {
        case channelView
        case profileView
    }
    
    /// Constraint, который будет изменять размер в соответствии с размером клавиатуры
    /// при её вызове.
    private var constraint: NSLayoutConstraint?
    /// Используется для анимированного изменения констреинтов на текущем экране
    private var view: UIView?
    private var viewCase: ViewCase?
    
    deinit {
        removeKeyboardNotifications()
    }
    
    /// Добавляет наблюдателя для отслеживания размеров клавиатуры
    /// - Parameters:
    ///   - view: Используется для анимированного изменения констреинтов на текущем экране
    ///   - constraint: Constraint, который будет изменять размер в соответствии с размером
    ///   клавиатуры при её вызове.
    func addChangeHeightObserver(
        for view: UIView,
        changeValueFor constraint: NSLayoutConstraint,
        with viewCase: ViewCase
    ) {
        self.constraint = constraint
        self.view = view
        self.viewCase = viewCase
        
        registerForKeyboardNotifications()
    }
    
    private func registerForKeyboardNotifications() {
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
        let keyboardAnimation = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        
        if let constraint = constraint {
            switch viewCase {
            case .channelView:
                constraint.constant = (keyboardFrameSize?.height ?? 0)
            case .profileView:
                constraint.constant = -(keyboardFrameSize?.height ?? 0) / 2
            default:
                Logger.error("Что то пошло не так")
            }
            UIView.animate(withDuration: keyboardAnimation) { [weak self] in
                self?.view?.layoutIfNeeded()
            }
        }
        
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardAnimation = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        
        if let constraint = constraint {
            switch viewCase {
            case .channelView:
                constraint.constant = .zero
            case .profileView:
                constraint.constant = 7
            default:
                Logger.error("Что то пошло не так")
            }
            
            UIView.animate(withDuration: keyboardAnimation) { [weak self] in
                self?.view?.layoutIfNeeded()
            }
        }
    }
}
