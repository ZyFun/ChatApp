//
//  ChannelViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 07.03.2022.
//

import UIKit

final class ChannelViewController: UIViewController {
    
    // MARK: - Public properties
    
    var channelTitle: String?
    var channelID: String = ""
    var messages: [Message] = []
    var mySenderId: String?
    
    // MARK: - Private properties
    
    private var observerKeyboard = NotificationKeyboardObserver()
    private var chatCoreDataService = ChatCoreDataService()
    private var messagesDB: [DBMessage] = []
    
    /// Свойство для активации и отображения логов в данном классе
    private let isLogActivate = true
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var messageToolbarView: UIView!
    @IBOutlet weak var channelTableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var messageToolBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomScreenConstraint: NSLayoutConstraint!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        fetchMessagesFromDBChannel()
        loadMessages()
    }
    
    // MARK: - IB Actions
    
    @IBAction func sendMessageButtonPressed() {
        guard !messageTextView.text.isEmpty else { return }
        
        if let mySenderId = mySenderId {
            sendMessage(
                channelID: channelID,
                senderID: mySenderId,
                message: messageTextView.text
            )
            
            // Возврат размеров панели отправки сообщений, после их изменения при написании многострочного текста
            messageToolBarHeightConstraint.constant = 80
        } else {
            Logger.warning(
                "ID Профиля не получено",
                showInConsole: isLogActivate)
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
    }
    
    func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        title = channelTitle
    }
    
    func setupTableView() {
        channelTableView.dataSource = self
        
        channelTableView.separatorStyle = .none
        
        registerCell()
    }
    
    func setupViews() {
        channelTableView.backgroundColor = .appColorLoadFor(.backgroundView)
        view.backgroundColor = .appColorLoadFor(.backgroundView)
    }
    
    func setupToolBar() {
        
        messageToolbarView.backgroundColor = .appColorLoadFor(.backgroundToolBar)
        messageToolbarView.layer.borderWidth = 0.5
        
        if ThemeManager.shared.currentTheme != Theme.night.rawValue {
            messageToolbarView.layer.borderColor = #colorLiteral(red: 0.6235294118, green: 0.6274509804, blue: 0.6431372549, alpha: 1)
        } else {
            messageToolbarView.layer.borderColor = #colorLiteral(red: 0.6235294118, green: 0.6274509804, blue: 0.6431372549, alpha: 0)
        }
        
        messageTextView.delegate = self
        messageTextView.layer.cornerRadius = 16
        messageTextView.layer.borderWidth = 0.5
        messageTextView.layer.borderColor = #colorLiteral(red: 0.6251094341, green: 0.6256788373, blue: 0.6430239081, alpha: 1)
        messageTextView.textContainer.lineFragmentPadding = 44
        messageTextView.backgroundColor = .appColorLoadFor(.textFieldToolBar)
        messageTextView.textColor = .appColorLoadFor(.text)
    }
    
    func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemGray
    }
    
    func scrollCellsToBottom() {
        if !messages.isEmpty {
            let lastRow = channelTableView.numberOfRows(inSection: 0) - 1
            let indexPath = IndexPath(row: lastRow, section: 0)
            channelTableView.scrollToRow(
                at: indexPath,
                at: .bottom,
                animated: false
            )
        }
    }
    
    func registerCell() {
        channelTableView.register(
            MessageCell.self,
            forCellReuseIdentifier: MessageCell.identifier
        )
    }
    
    // MARK: - Firestore request
    
    func loadMessages() {
        activityIndicator.startAnimating()
        
        FirestoreService.shared.fetchMessages(
            channelID: channelID
        ) { [weak self] result in
            
            switch result {
            case .success(let messages):
                self?.messages = messages
                // TODO: ([27.03.2022]) Посмотреть где оптимальнее делать сортировку
                self?.messages.sort(by: { $0.created < $1.created })
                self?.channelTableView.reloadData()
                self?.scrollCellsToBottom()
                self?.activityIndicator.stopAnimating()
                
                Logger.info(
                    "Отображены данные из Firebase",
                    showInConsole: self?.isLogActivate
                )
                
                self?.saveLoaded(messages)
            case .failure(let error):
                Logger.error(
                    "\(error.localizedDescription)",
                    showInConsole: self?.isLogActivate
                )
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
    
    func fetchMessagesFromDBChannel() {
        chatCoreDataService.fetchChannels { [weak self] result in
            switch result {
            case .success(let channels):
                if let currentChannel = channels.filter({ $0.identifier == self?.channelID }).first {
                    if let channelMessages = currentChannel.messages?.allObjects as? [DBMessage] {
                        self?.messagesDB = channelMessages
                        self?.messagesDB.sort(by: { $0.created ?? Date() < $1.created ?? Date() })
                        self?.channelTableView.reloadData()
                        
                        Logger.info(
                            "=====Отображены данные из Core Data=====",
                            showInConsole: self?.isLogActivate
                        )
                    }
                }
            case .failure(let error):
                Logger.error(
                    "\(error.localizedDescription)",
                    showInConsole: self?.isLogActivate
                )
            }
        }
    }
    
    func saveLoaded(_ messages: [Message]) {
        Logger.info(
            "=====Процесс обновления сообщений в CoreData запущен=====",
            showInConsole: isLogActivate
        )
        
        chatCoreDataService.performSave { [weak self] context in
            var messagesDB: [DBMessage] = []
            var currentChannel: DBChannel?
            
            self?.chatCoreDataService.fetchChannels(from: context) { result in
                switch result {
                case .success(let channels):
                    if let channel = channels.filter({ $0.identifier == self?.channelID }).first {
                        currentChannel = channel
                        
                        Logger.info(
                            "Загружено сообщений из базы: \(channel.messages?.count ?? 0)",
                            showInConsole: self?.isLogActivate
                        )
                        
                        if let channelMessages = channel.messages?.allObjects as? [DBMessage] {
                            messagesDB = channelMessages
                        }
                    }
                case .failure(let error):
                    Logger.error(
                        "\(error.localizedDescription)",
                        showInConsole: self?.isLogActivate
                    )
                }
            }
            
            Logger.info(
                "Запуск процесса поиска новых данных",
                showInConsole: self?.isLogActivate
            )
            
            messages.forEach { message in
                
                guard messagesDB.filter({
                    $0.created == message.created &&
                    $0.senderName == message.senderName
                }).first == nil else {
                    Logger.info(
                        "Сообщение уже есть в базе",
                        showInConsole: self?.isLogActivate
                    )
                    
                    return
                }
                
                Logger.info(
                    "Найдено новое сообщение",
                    showInConsole: self?.isLogActivate
                )
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

// MARK: - Table view data source

extension ChannelViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        let count = messages.isEmpty
        ? messagesDB.count
        : messages.count
        
        return count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        // TODO: ([03.04.2022]) Нужен менеджер в виде парсера для избавления от дублирования
        // парсер должен будет возвращать данные в массив, чтобы можно было работать с одном типом данных
        // а не выбирать между двумя как сейчас.
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MessageCell.identifier,
            for: indexPath
        ) as? MessageCell else { return UITableViewCell() }
        
        if messages.isEmpty {
            let message = messagesDB[indexPath.row]
            
            if message.senderId != mySenderId {
                cell.configureIncomingMessage(
                    senderName: message.senderName,
                    textMessage: message.content ?? "", // TODO: ([03.04.2022]) Разобраться почему в БД опционал. Аналогично по остальным
                    // Видимо это баг xcode, так как галочку я снял, а в файле значения остались опциональными
                    dateCreated: message.created ?? Date()
                )
            } else {
                cell.configureOutgoingMessage(
                    senderName: message.senderName,
                    textMessage: message.content ?? "",
                    dateCreated: message.created ?? Date()
                )
            }
        } else {
            let message = messages[indexPath.row]
            
            if message.senderId != mySenderId {
                cell.configureIncomingMessage(
                    senderName: message.senderName,
                    textMessage: message.content,
                    dateCreated: message.created
                )
            } else {
                cell.configureOutgoingMessage(
                    senderName: message.senderName,
                    textMessage: message.content,
                    dateCreated: message.created
                )
            }
        }
        
        return cell
    }
}

// MARK: - Text View Delegate

extension ChannelViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollCellsToBottom()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if messageTextView.contentSize.height <= 130 {
            messageToolBarHeightConstraint.constant = messageTextView.contentSize.height + 48
        }
    }
}
