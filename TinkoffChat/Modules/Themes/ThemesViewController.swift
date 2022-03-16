//
//  ThemesViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 11.03.2022.
//

import UIKit

final class ThemesViewController: UIViewController {
    // MARK: - Private properties
    private let classicColorBackgroundView = UIColor.appColorSetup(.classic, .backgroundView)
    private let classicColorBackgroundNavBar = UIColor.appColorSetup(.classic, .backgroundNavBar)
    private let classicColorLeftMessage = UIColor.appColorSetup(.classic, .leftMessage)
    private let classicColorRightMessage = UIColor.appColorSetup(.classic, .rightMessage)
    
    private let dayColorBackgroundView = UIColor.appColorSetup(.day, .backgroundView)
    private let dayColorBackgroundNavBar = UIColor.appColorSetup(.day, .backgroundNavBar)
    private let dayColorLeftMessage = UIColor.appColorSetup(.day, .leftMessage)
    private let dayColorRightMessage = UIColor.appColorSetup(.day, .rightMessage)
    
    private let nightColorBackgroundView = UIColor.appColorSetup(.night, .backgroundView)
    private let nightBackgroundNavBar = UIColor.appColorSetup(.night, .backgroundNavBar)
    private let nightColorLeftMessage = UIColor.appColorSetup(.night, .leftMessage)
    private let nightColorRightMessage = UIColor.appColorSetup(.night, .rightMessage)
    
    // MARK: - Public properties
    var completion: (
        (
            _ backgroundView: UIColor,
            _ backgroundNavBar: UIColor,
            _ text: UIColor
        ) -> ()
    )?
    
    // Тут может быть retain cycle. Так как под делегат подписан экран ConversationsListViewController, а с него идет ссылка на текущий экран, может возникнуть утечка памяти, если не указать weak у свойства. Экраны будут всегда ссылаться друг на друга и никогда не выгрузятся из памяти, потому что счетчик ссылок не обнулится. Обратная связь всегда должна быть обозначена слабой ссылкой.
    weak var themeDelegate: ThemeDelegate?
    
    // MARK: - IB Outlets
    // Тут может быть retain cycle если не указать weak. Например когда приложение получит от системы предупреждение о нехватки памяти и приоритеты будут у другого приложения, экран выгрузится из памяти. А свойство нет, так как оно будет ссылаться само на себя и счетчик ссылок у него не обнулится.
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
        selectedCurrentTheme()
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
            
//            themeDelegate?.updateTheme(
//                backgroundViewTheme: classicColorBackgroundView,
//                backgroundNavBarTheme: classicColorBackgroundNavBar,
//                textTheme: .black)
            
            // Для проверки работы делегата и замыкания нужно закомментировать. В делегате настроены не все цвета
            StorageManager.shared.saveTheme(theme: .classic)
            setNeedsStatusBarAppearanceUpdate()
            
            completion?(
                classicColorBackgroundView,
                classicColorBackgroundNavBar,
                .black
            )
        case dayMainView:
            setSelectedState(dayChatView)
            setDeselectedState(classicChatView)
            setDeselectedState(nightChatView)
            
            setupLabelsColorForLightTheme()
            view.backgroundColor = dayColorBackgroundView
            
//            themeDelegate?.updateTheme(
//                backgroundViewTheme: dayColorBackgroundView,
//                backgroundNavBarTheme: dayColorBackgroundNavBar,
//                textTheme: .black)
            
            // Для проверки работы делегата и замыкания нужно закомментировать. В делегате настроены не все цвета
            StorageManager.shared.saveTheme(theme: .day)
            setNeedsStatusBarAppearanceUpdate()
            
            completion?(
                dayColorBackgroundView,
                dayColorBackgroundNavBar,
                .black
            )
        case nightMainView:
            setSelectedState(nightChatView)
            setDeselectedState(classicChatView)
            setDeselectedState(dayChatView)
            
            setupLabelsColorForDartTheme()
            view.backgroundColor = nightColorBackgroundView
            
//            themeDelegate?.updateTheme(
//                backgroundViewTheme: nightColorBackgroundView,
//                backgroundNavBarTheme: nightBackgroundNavBar,
//                textTheme: .white)
            
            // Для проверки работы делегата и замыкания нужно закомментировать. В делегате настроены не все цвета
            StorageManager.shared.saveTheme(theme: .night)
            setNeedsStatusBarAppearanceUpdate()
            
            completion?(
                nightColorBackgroundView,
                nightBackgroundNavBar,
                .white
            )
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
        view.backgroundColor = .appColorLoadFor(.backgroundView)
        
        classicLabel.textColor = .appColorLoadFor(.text)
        dayLabel.textColor = .appColorLoadFor(.text)
        nightLabel.textColor = .appColorLoadFor(.text)
    }
    
    func selectedCurrentTheme() {
        let currentTheme = ThemeManager.shared.currentTheme
        
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
