//
//  ChannelViewController.swift
//  ChatApp
//
//  Created by Дмитрий Данилин on 07.03.2022.
//

import UIKit

final class ChannelViewController: UIViewController {
    
    // MARK: - Public properties
    
    var mySenderId: String?
    var currentChannel: DBChannel?
    
    // MARK: - Private properties
    
    private var observerKeyboard: NotificationKeyboardObserverProtocol
    private let themeManager: ThemeManagerProtocol
    private let chatCoreDataService: ChatCoreDataServiceProtocol
    private let messageService: MessageServiceProtocol
    private var resultManager: ChannelFetchedResultsManagerProtocol
    private var dataSourceManager: ChannelDataSourceManagerProtocol
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var messageToolbarView: UIView!
    @IBOutlet weak var channelTableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var messageToolBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomScreenConstraint: NSLayoutConstraint!
    
    // MARK: - Initializer
    
    init(
        messageService: MessageServiceProtocol,
        chatCoreDataService: ChatCoreDataServiceProtocol,
        resultManager: ChannelFetchedResultsManagerProtocol
    ) {
        self.chatCoreDataService = chatCoreDataService
        self.resultManager = resultManager
        observerKeyboard = NotificationKeyboardObserver()
        self.messageService = messageService
        themeManager = ThemeManager.shared
        dataSourceManager = ChannelDataSourceManager(
            resultManager: resultManager
        )
        super.init(
            nibName: String(describing: ChannelViewController.self),
            bundle: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        dataSourceManager.mySenderId = mySenderId
        
        activityIndicator.startAnimating()
        messageService.loadMessagesFromFirebase(
            for: currentChannel,
            with: chatCoreDataService) { [weak self] in
                self?.activityIndicator.stopAnimating()
            }
    }
    
    // MARK: - IB Actions
    
    @IBAction func sendImageButtonPressed(_ sender: Any) {
        let loadedImageLibraryVC = LoadedImageLibraryViewController()
        loadedImageLibraryVC.isOpenForSendMessage = true
        present(loadedImageLibraryVC, animated: true)
        
        loadedImageLibraryVC.dataSourceProvider?.didSelectForSendImage = { [weak self] imageURL in
            guard let channelID = self?.currentChannel?.identifier else {
                Logger.error("Отсутствует идентификатор канала")
                return
            }
            
            if let mySenderId = self?.mySenderId {
                self?.messageService.sendMessage(
                    channelID: channelID,
                    senderID: mySenderId,
                    message: "Нет поддержки API:\n \(imageURL)"
                ) {
                    self?.scrollCellsToBottom(animated: true)
                    Logger.info("Сообщение отправлено")
                }
            }
            
            loadedImageLibraryVC.dismiss(animated: true)
        }
    }
    
    @IBAction func sendMessageButtonPressed() {
        guard !messageTextView.text.isEmpty else {
            Logger.warning("Сообщение не введено")
            return
        }
        guard let channelID = currentChannel?.identifier else {
            Logger.error("Отсутствует идентификатор канала")
            return
        }
        
        if let mySenderId = mySenderId {
            messageService.sendMessage(
                channelID: channelID,
                senderID: mySenderId,
                message: messageTextView.text
            ) { [weak self] in
                self?.messageTextView.text = ""
            }
            
            // Возврат размеров панели отправки сообщений, после их изменения при написании многострочного текста
            messageToolBarHeightConstraint.constant = 80
            scrollCellsToBottom(animated: true)
        } else {
            Logger.warning("ID Профиля не получено")
        }
    }
}

// MARK: - Private methods

private extension ChannelViewController {
    func setup() {
        setupNavigationBar()
        setupTableView()
        setupViews()
        setupActivityIndicator()
        setupToolBar()
        setupKeyboardNotificationsObserver()
        setTapGestureForDismissKeyboard()
        
        resultManager.mySenderId = mySenderId
        resultManager.tableView = channelTableView
    }
    
    func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        title = currentChannel?.name
    }
    
    func setupTableView() {
        channelTableView.separatorStyle = .none
        // Развернул отображение таблицы, чтобы первая ячейка была снизу
        channelTableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        // TODO: ([12.04.2022]) Найти решение, как развернуть направление скролла по тапу или сделать свои кнопки
        // в идеале, сделать подъем на 1 экран, а не листать до конца.
        channelTableView.scrollsToTop = false
        channelTableView.dataSource = dataSourceManager as? UITableViewDataSource
        
        registerCell()
    }
    
    func setupViews() {
        channelTableView.backgroundColor = themeManager.appColorLoadFor(.backgroundView)
        view.backgroundColor = themeManager.appColorLoadFor(.backgroundView)
    }
    
    func setupToolBar() {
        
        messageToolbarView.backgroundColor = themeManager.appColorLoadFor(.backgroundToolBar)
        messageToolbarView.layer.borderWidth = 0.5
        
        if themeManager.currentTheme != Theme.night.rawValue {
            messageToolbarView.layer.borderColor = #colorLiteral(red: 0.6235294118, green: 0.6274509804, blue: 0.6431372549, alpha: 1)
        } else {
            messageToolbarView.layer.borderColor = #colorLiteral(red: 0.6235294118, green: 0.6274509804, blue: 0.6431372549, alpha: 0)
        }
        
        messageTextView.delegate = self
        messageTextView.layer.cornerRadius = 16
        messageTextView.layer.borderWidth = 0.5
        messageTextView.layer.borderColor = #colorLiteral(red: 0.6251094341, green: 0.6256788373, blue: 0.6430239081, alpha: 1)
        messageTextView.textContainer.lineFragmentPadding = 44
        messageTextView.backgroundColor = themeManager.appColorLoadFor(.textFieldToolBar)
        messageTextView.textColor = themeManager.appColorLoadFor(.text)
    }
    
    func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemGray
    }
    
    func registerCell() {
        channelTableView.register(
            MessageCell.self,
            forCellReuseIdentifier: MessageCell.identifier
        )
    }
    
    func scrollCellsToBottom(animated: Bool) {
        guard let isNoObjects = resultManager.fetchedResultsController.fetchedObjects?.isEmpty else { return }
        if !isNoObjects {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let indexPath = IndexPath(row: 0, section: 0)
                self.channelTableView.scrollToRow(
                    at: indexPath,
                    at: .bottom,
                    animated: animated
                )
            }
        }
    }
    
    // MARK: - Keyboard
    
    func setupKeyboardNotificationsObserver() {
        observerKeyboard.addChangeHeightObserver(
            for: view,
            changeValueFor: bottomScreenConstraint,
            with: .channelView
        )
    }
    
    func setTapGestureForDismissKeyboard() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Text View Delegate

extension ChannelViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollCellsToBottom(animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if messageTextView.contentSize.height <= 130 {
            messageToolBarHeightConstraint.constant = messageTextView.contentSize.height + 48
        }
    }
}
