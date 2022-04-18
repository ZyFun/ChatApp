//
//  ChannelViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 07.03.2022.
//

import UIKit

final class ChannelViewController: UIViewController {
    
    // MARK: - Public properties
    
    var mySenderId: String?
    var currentChannel: DBChannel?
    
    // MARK: - Private properties
    
    private var observerKeyboard = NotificationKeyboardObserver()
    
    private let themeManager: ThemeManagerProtocol
    private let chatCoreDataService: ChatCoreDataServiceProtocol
    private var resultManager: ChannelFetchedResultsManagerProtocol
    private var dataSourceManager: ChannelDataSourceManagerProtocol?
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var messageToolbarView: UIView!
    @IBOutlet weak var channelTableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var messageToolBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomScreenConstraint: NSLayoutConstraint!
    
    // MARK: - Initializer
    
    init(
        chatCoreDataService: ChatCoreDataServiceProtocol,
        resultManager: ChannelFetchedResultsManagerProtocol
    ) {
        self.chatCoreDataService = chatCoreDataService
        self.resultManager = resultManager
        self.themeManager = ThemeManager.shared
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
        
        // TODO: ([16.0472022]) Я не понимаю как заставить работать его через протокол :(
        // не могу понять, как datasource назначить без инита таблицы, при ините класса менеджера,
        // и при передаче текущей таблицы, уже не ей управляются методы datasorce
        // Аналогично и с резалт контроллером, пришлось инитить его при ините текущего класса
        // чтобы сразу передать этот параметр и сделать его делегатом.
        dataSourceManager = ChannelDataSourceManager(
            resultManager: resultManager,
            tableView: channelTableView
        )
        
        dataSourceManager?.mySenderId = mySenderId
        
        loadMessagesFromFirebase()
    }
    
    // MARK: - IB Actions
    
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
            sendMessage(
                channelID: channelID,
                senderID: mySenderId,
                message: messageTextView.text
            )
            
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
    
    // MARK: - Firestore request
    
    func loadMessagesFromFirebase() {
        activityIndicator.startAnimating()
        guard let channelID = currentChannel?.identifier else {
            Logger.error("Отсутствует идентификатор канала")
            return
        }
        
        FirestoreService.shared.fetchMessages(
            channelID: channelID
        ) { [weak self] result in
            
            switch result {
            case .success(let messages):
                Logger.info("Данные из Firebase загружены")
                self?.saveLoaded(messages)
                self?.activityIndicator.stopAnimating()
            case .failure(let error):
                Logger.error(error.localizedDescription)
            }
        }
    }
    
    func sendMessage(channelID: String, senderID: String, message: String) {
        FirestoreService.shared.sendMessage(
            channelID: channelID,
            message: message,
            senderID: senderID
        )
        
        messageTextView.text = ""
    }
    
    // MARK: - Core Data Cache
    
    func saveLoaded(_ messages: [Message]) {
        Logger.info("=====Процесс обновления сообщений в CoreData запущен=====")
        guard let channelID = currentChannel?.identifier else {
            Logger.error("Отсутствует идентификатор канала")
            return
        }
        
        chatCoreDataService.performSave { [weak self] context in
            var messagesDB: [DBMessage] = []
            var currentChannel: DBChannel?
            
            self?.chatCoreDataService.fetchChannels(from: context) { result in
                switch result {
                case .success(let channels):
                    if let channel = channels.filter({ $0.identifier == channelID }).first {
                        currentChannel = channel
                        
                        Logger.info("Загружено сообщений из базы: \(channel.messages?.count ?? 0)")
                        
                        if let channelMessages = channel.messages?.allObjects as? [DBMessage] {
                            messagesDB = channelMessages
                        }
                    }
                case .failure(let error):
                    Logger.error("\(error.localizedDescription)")
                }
            }
            
            Logger.info("Запуск процесса поиска новых данных")
            
            messages.forEach { message in
                
                guard messagesDB.filter({
                    $0.messageId == message.messageId
                }).first == nil else {
                    Logger.info("Сообщение уже есть в базе")
                    return
                }
                
                Logger.info("Найдено новое сообщение")
                self?.chatCoreDataService.messageSave(
                    message,
                    currentChannel: currentChannel,
                    context: context
                )
            }
        }
    }
    
    // MARK: - Keyboard
    
    func setupKeyboardNotificationsObserver() {
        observerKeyboard.addChangeHeightObserver(
            for: view,
            changeValueFor: bottomScreenConstraint
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
