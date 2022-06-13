//
//  ThemesViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 11.03.2022.
//

import UIKit

final class ThemesViewController: UIViewController {
    // MARK: - Private properties
    
    private var themeManager: ThemeManagerProtocol
    private let storageManager: StorageManagerProtocol
    private var customAnimation: CustomAnimationProtocol
    
    private lazy var classicColorBackgroundView = themeManager.appColorSetup(.classic, .backgroundView)
    private lazy var classicColorBackgroundNavBar = themeManager.appColorSetup(.classic, .backgroundNavBar)
    private lazy var classicColorLeftMessage = themeManager.appColorSetup(.classic, .leftMessage)
    private lazy var classicColorRightMessage = themeManager.appColorSetup(.classic, .rightMessage)
    
    private lazy var dayColorBackgroundView = themeManager.appColorSetup(.day, .backgroundView)
    private lazy var dayColorBackgroundNavBar = themeManager.appColorSetup(.day, .backgroundNavBar)
    private lazy var dayColorLeftMessage = themeManager.appColorSetup(.day, .leftMessage)
    private lazy var dayColorRightMessage = themeManager.appColorSetup(.day, .rightMessage)
    
    private lazy var nightColorBackgroundView = themeManager.appColorSetup(.night, .backgroundView)
    private lazy var nightBackgroundNavBar = themeManager.appColorSetup(.night, .backgroundNavBar)
    private lazy var nightColorLeftMessage = themeManager.appColorSetup(.night, .leftMessage)
    private lazy var nightColorRightMessage = themeManager.appColorSetup(.night, .rightMessage)
    
    // MARK: - Public properties
    
    var completion: (() -> Void)?
    
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
    
    // MARK: - Initializer
    
    init() {
        themeManager = ThemeManager.shared
        storageManager = StorageManager()
        customAnimation = CustomAnimation()
        super.init(
            nibName: String(describing: ThemesViewController.self),
            bundle: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Используется для избегания бага отображения гербов с мултитачем
        view.isExclusiveTouch = true
        
        setupUI()
        selectedCurrentTheme()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        customAnimation.deleteCAEmitterLayer(from: view)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        customAnimation.deleteCAEmitterLayer(from: view)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let coordinate = touch?.location(in: view)
        customAnimation.showCoatOfArms(into: view, for: coordinate)
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
            setSelectedState(classicChatView)
            setDeselectedState(dayChatView)
            setDeselectedState(nightChatView)
            
            setupLabelsColorForLightTheme()
            view.backgroundColor = classicColorBackgroundView
            
            storageManager.saveTheme(theme: .classic) { theme in
                 themeManager.currentTheme = theme.rawValue
            }
            setNeedsStatusBarAppearanceUpdate()
            
            completion?()
        case dayMainView:
            setSelectedState(dayChatView)
            setDeselectedState(classicChatView)
            setDeselectedState(nightChatView)
            
            setupLabelsColorForLightTheme()
            view.backgroundColor = dayColorBackgroundView
            
            storageManager.saveTheme(theme: .day) { theme in
                themeManager.currentTheme = theme.rawValue
            }
            setNeedsStatusBarAppearanceUpdate()
            
            completion?()
        case nightMainView:
            setSelectedState(nightChatView)
            setDeselectedState(classicChatView)
            setDeselectedState(dayChatView)
            
            setupLabelsColorForDartTheme()
            view.backgroundColor = nightColorBackgroundView
            
            storageManager.saveTheme(theme: .night) { theme in
                themeManager.currentTheme = theme.rawValue
            }
            setNeedsStatusBarAppearanceUpdate()
            
            completion?()
        default:
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
    
    func setDeselectedState(_ chatView: UIView) {
        chatView.layer.borderColor = UIColor.systemGray.cgColor
        chatView.layer.borderWidth = 1
    }
    
    func setSelectedState(_ chatView: UIView) {
        chatView.layer.borderColor = #colorLiteral(red: 0, green: 0.4730627537, blue: 1, alpha: 1)
        chatView.layer.borderWidth = 3
    }
    
    func setupThemeVC() {
        view.backgroundColor = themeManager.appColorLoadFor(.backgroundView)
        
        classicLabel.textColor = themeManager.appColorLoadFor(.text)
        dayLabel.textColor = themeManager.appColorLoadFor(.text)
        nightLabel.textColor = themeManager.appColorLoadFor(.text)
    }
    
    func selectedCurrentTheme() {
        let currentTheme = themeManager.currentTheme
        
        switch currentTheme {
        case Theme.classic.rawValue:
            setSelectedState(classicChatView)
        case Theme.day.rawValue:
            setSelectedState(dayChatView)
        case Theme.night.rawValue:
            setSelectedState(nightChatView)
        default:
            break
        }
    }
}
