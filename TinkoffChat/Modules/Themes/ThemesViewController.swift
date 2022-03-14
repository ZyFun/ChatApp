//
//  ThemesViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 11.03.2022.
//

import UIKit

final class ThemesViewController: UIViewController {
    // MARK: - Private properties
    private let classicColorBackgroundView = UIColor.appColorSetup(.Classic, .backgroundView)
    private let classicColorBackgroundNavBar = UIColor.appColorSetup(.Classic, .backgroundNavBar)
    private let classicColorLeftMessage = UIColor.appColorSetup(.Classic, .leftMessage)
    private let classicColorRightMessage = UIColor.appColorSetup(.Classic, .rightMessage)
    
    private let dayColorBackgroundView = UIColor.appColorSetup(.Day, .backgroundView)
    private let dayColorBackgroundNavBar = UIColor.appColorSetup(.Day, .backgroundNavBar)
    private let dayColorLeftMessage = UIColor.appColorSetup(.Day, .leftMessage)
    private let dayColorRightMessage = UIColor.appColorSetup(.Day, .rightMessage)
    
    private let nightColorBackgroundView = UIColor.appColorSetup(.Night, .backgroundView)
    private let nightBackgroundNavBar = UIColor.appColorSetup(.Night, .backgroundNavBar)
    private let nightColorLeftMessage = UIColor.appColorSetup(.Night, .leftMessage)
    private let nightColorRightMessage = UIColor.appColorSetup(.Night, .rightMessage)
    
    // MARK: - Public properties
    var completion: (
        (
            _ backgroundView: UIColor,
            _ backgroundNavBar: UIColor,
            _ text: UIColor
        ) -> ()
    )?
    
    weak var themeDelegate: ThemeDelegate?
    
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
        setupThemeVC()
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
            backgroundColor: classicColorBackgroundView,
            colorLeft: classicColorLeftMessage,
            colorRight: classicColorRightMessage
        )
        
        setupThemeButton(
            with: dayMainView,
            label: dayLabel,
            chatView: dayChatView,
            messageLeft: dayMessageLeftView,
            messageRight: dayMessageRightView,
            backgroundColor: dayColorBackgroundView,
            colorLeft: dayColorLeftMessage,
            colorRight: dayColorRightMessage
        )
        
        setupThemeButton(
            with: nightMainView,
            label: nightLabel,
            chatView: nightChatView,
            messageLeft: nightMessageLeftView,
            messageRight: nightMessageRightView,
            backgroundColor: nightColorBackgroundView,
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
            view.backgroundColor = classicColorBackgroundView
            
//            themeDelegate?.updateTheme(
//                backgroundViewTheme: classicColorBackgroundView,
//                backgroundNavBarTheme: classicColorBackgroundNavBar,
//                textTheme: .black)
            
            StorageManager.shared.saveTheme(theme: .Classic)
            setNeedsStatusBarAppearanceUpdate()
            
            completion?(
                classicColorBackgroundView,
                classicColorBackgroundNavBar,
                .black
            )
        case dayMainView:
            setupSelectedState(dayChatView)
            setupDeselectedState(classicChatView)
            setupDeselectedState(nightChatView)
            
            setupLabelsColorForLightTheme()
            view.backgroundColor = dayColorBackgroundView
            
//            themeDelegate?.updateTheme(
//                backgroundViewTheme: dayColorBackgroundView,
//                backgroundNavBarTheme: dayColorBackgroundNavBar,
//                textTheme: .black)
            
            StorageManager.shared.saveTheme(theme: .Day)
            setNeedsStatusBarAppearanceUpdate()
            
            completion?(
                dayColorBackgroundView,
                dayColorBackgroundNavBar,
                .black
            )
        case nightMainView:
            setupSelectedState(nightChatView)
            setupDeselectedState(classicChatView)
            setupDeselectedState(dayChatView)
            
            setupLabelsColorForDartTheme()
            view.backgroundColor = nightColorBackgroundView
            
//            themeDelegate?.updateTheme(
//                backgroundViewTheme: nightColorBackgroundView,
//                backgroundNavBarTheme: nightBackgroundNavBar,
//                textTheme: .white)
            
            StorageManager.shared.saveTheme(theme: .Night)
            setNeedsStatusBarAppearanceUpdate()
            
            completion?(
                nightColorBackgroundView,
                nightBackgroundNavBar,
                .white
            )
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
    
    func setupThemeVC() {
        view.backgroundColor = .appColorLoadFor(.backgroundView)
        
        classicLabel.textColor = .appColorLoadFor(.text)
        dayLabel.textColor = .appColorLoadFor(.text)
        nightLabel.textColor = .appColorLoadFor(.text)
    }
    
    // TODO: Добавить метод, который будет выделять кнопку текущей темы при входе на экран
}
