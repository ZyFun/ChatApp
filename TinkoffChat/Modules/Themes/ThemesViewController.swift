//
//  ThemesViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 11.03.2022.
//

import UIKit

final class ThemesViewController: UIViewController {
    // MARK: - Private properties
    private let classicColorBackground = UIColor.white
    private let classicColorLeftMessage = #colorLiteral(red: 0.8745099902, green: 0.874509871, blue: 0.874509871, alpha: 1)
    private let classicColorRightMessage = #colorLiteral(red: 0.8347972035, green: 0.9761014581, blue: 0.7518735528, alpha: 1)
    
    private let dayColorBackground = UIColor.white
    private let dayColorLeftMessage = #colorLiteral(red: 0.9169014692, green: 0.9215699434, blue: 0.9302648902, alpha: 1)
    private let dayColorRightMessage = #colorLiteral(red: 0.153665185, green: 0.5354442, blue: 1, alpha: 1)
    
    private let nightColorBackground = #colorLiteral(red: 0.02352941036, green: 0.02352941409, blue: 0.02352941036, alpha: 1)
    private let nightColorLeftMessage = #colorLiteral(red: 0.1803921461, green: 0.1803921461, blue: 0.1803921461, alpha: 1)
    private let nightColorRightMessage = #colorLiteral(red: 0.3607842922, green: 0.3607842922, blue: 0.3607842922, alpha: 1)
    
    // MARK: - IB Outlets
    @IBOutlet weak var classicMainView: UIView!
    @IBOutlet weak var classicLabel: UILabel!
    @IBOutlet weak var classicChatView: UIView!
    @IBOutlet weak var classicMessageLeftView: UIView!
    @IBOutlet weak var classicMessageRightView: UIView!
    
    @IBOutlet weak var dayMainView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayChatView: UIView!
    @IBOutlet weak var dayMessageLeftView: UIView!
    @IBOutlet weak var dayMessageRightView: UIView!
    
    @IBOutlet weak var nightMainView: UIView!
    @IBOutlet weak var nightLabel: UILabel!
    @IBOutlet weak var nightChatView: UIView!
    @IBOutlet weak var nightMessageLeftView: UIView!
    @IBOutlet weak var nightMessageRightView: UIView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
}

// MARK: - Private methods
private extension ThemesViewController {
    func setupUI() {
        setupButtons()
    }
    
    func setupButtons() {
        setupThemeButton(
            with: classicMainView,
            label: classicLabel,
            chatView: classicChatView,
            messageLeft: classicMessageLeftView,
            messageRight: classicMessageRightView,
            backgroundColor: classicColorBackground,
            colorLeft: classicColorLeftMessage,
            colorRight: classicColorRightMessage
        )
        
        setupThemeButton(
            with: dayMainView,
            label: dayLabel,
            chatView: dayChatView,
            messageLeft: dayMessageLeftView,
            messageRight: dayMessageRightView,
            backgroundColor: dayColorBackground,
            colorLeft: dayColorLeftMessage,
            colorRight: dayColorRightMessage
        )
        
        setupThemeButton(
            with: nightMainView,
            label: nightLabel,
            chatView: nightChatView,
            messageLeft: nightMessageLeftView,
            messageRight: nightMessageRightView,
            backgroundColor: nightColorBackground,
            colorLeft: nightColorLeftMessage,
            colorRight: nightColorRightMessage
        )
    }
    
    func setupThemeButton(
        with themeMainView: UIView,
        label: UILabel,
        chatView: UIView,
        messageLeft: UIView,
        messageRight: UIView,
        backgroundColor: UIColor,
        colorLeft: UIColor,
        colorRight: UIColor
    ) {
        themeMainView.backgroundColor = .clear
        
        label.textColor = .label
        
        chatView.layer.borderColor = UIColor.systemGray.cgColor
        chatView.layer.borderWidth = 1
        chatView.layer.cornerRadius = 10
        chatView.backgroundColor = backgroundColor
        
        messageLeft.backgroundColor = colorLeft
        messageLeft.layer.cornerRadius = 10
        
        messageRight.backgroundColor = colorRight
        messageRight.layer.cornerRadius = messageLeft.layer.cornerRadius
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(buttonPressed))
        themeMainView.addGestureRecognizer(tap)
    }
    
    @objc func buttonPressed() {
        classicChatView.layer.borderColor = #colorLiteral(red: 0, green: 0.4730627537, blue: 1, alpha: 1)
        classicChatView.layer.borderWidth = 2
    }
}
