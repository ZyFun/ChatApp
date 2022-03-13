//
//  ThemesViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 11.03.2022.
//

import UIKit

final class ThemesViewController: UIViewController {
    // MARK: - Private properties
    private let classicColorBackground = UIColor.appColor(.Classic, .background)
    private let classicColorLeftMessage = UIColor.appColor(.Classic, .leftMessage)
    private let classicColorRightMessage = UIColor.appColor(.Classic, .rightMessage)
    
    private let dayColorBackground = UIColor.appColor(.Day, .background)
    private let dayColorLeftMessage = UIColor.appColor(.Day, .leftMessage)
    private let dayColorRightMessage = UIColor.appColor(.Day, .rightMessage)
    
    private let nightColorBackground = UIColor.appColor(.Night, .background)
    private let nightColorLeftMessage = UIColor.appColor(.Night, .leftMessage)
    private let nightColorRightMessage = UIColor.appColor(.Night, .rightMessage)
    
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
        setupNavigationBar()
        setupThemeButtons()
    }
    
    func setupNavigationBar() {
        title = "Settings"
        navigationItem.largeTitleDisplayMode = .never
        
        setupNavBarButtons()
    }
    
    func setupNavBarButtons() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeVC))
        
        navigationItem.rightBarButtonItem = cancelButton
    }
    
    @objc func closeVC() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupThemeButtons() {
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
        
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(buttonPressed)
        )
        
        themeMainView.addGestureRecognizer(tap)
    }
    
    @objc func buttonPressed(sender: UITapGestureRecognizer) {
        
        switch sender.view {
        case classicMainView:
            setupSelectedState(classicChatView)
            setupDeselectedState(dayChatView)
            setupDeselectedState(nightChatView)
            
            setupLabelsColorForLightTheme()
            view.backgroundColor = #colorLiteral(red: 0.9169014692, green: 0.9215699434, blue: 0.9302648902, alpha: 1)
        case dayMainView:
            setupSelectedState(dayChatView)
            setupDeselectedState(classicChatView)
            setupDeselectedState(nightChatView)
            
            setupLabelsColorForLightTheme()
            view.backgroundColor = .white
        case nightMainView:
            setupSelectedState(nightChatView)
            setupDeselectedState(classicChatView)
            setupDeselectedState(dayChatView)
            
            setupLabelsColorForDartTheme()
            view.backgroundColor = nightColorBackground
        case .none:
            break
        case .some(_):
            break
        }
    }
    
    func setupLabelsColorForDartTheme() {
        classicLabel.textColor = .white
        dayLabel.textColor = .white
        nightLabel.textColor = .white
    }
    
    func setupLabelsColorForLightTheme() {
        classicLabel.textColor = .black
        dayLabel.textColor = .black
        nightLabel.textColor = .black
    }
    
    func setupDeselectedState(_ chatView: UIView) {
        chatView.layer.borderColor = UIColor.systemGray.cgColor
        chatView.layer.borderWidth = 1
    }
    
    func setupSelectedState(_ chatView: UIView) {
        chatView.layer.borderColor = #colorLiteral(red: 0, green: 0.4730627537, blue: 1, alpha: 1)
        chatView.layer.borderWidth = 3
    }
}
