//
//  ChannelViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 07.03.2022.
//

import UIKit
import CoreData

final class ChannelViewController: UIViewController {
    
    // MARK: - Public properties
    
    var mySenderId: String?
    var currentChannel: DBChannel?
    
    // MARK: - Private properties
    
    private var observerKeyboard = NotificationKeyboardObserver()
    
    private lazy var fetchedResultsController = ChatCoreDataService.shared.fetchResultController(
        entityName: String(describing: DBMessage.self),
        keyForSort: #keyPath(DBMessage.created),
        sortAscending: true,
        currentChannel: currentChannel
    )
    
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
        
        fetchedResultsController.delegate = self
        
        setup()
        loadMessagesFromCoreData()
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
    }
    
    func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        title = currentChannel?.name
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
    
    func registerCell() {
        channelTableView.register(
            MessageCell.self,
            forCellReuseIdentifier: MessageCell.identifier
        )
    }
    
    func scrollCellsToBottom(animated: Bool) {
        guard let isNoObjects = fetchedResultsController.fetchedObjects?.isEmpty else { return }
        if !isNoObjects {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                let lastRow = self.channelTableView.numberOfRows(inSection: 0) - 1
                guard lastRow > 0 else { return }
                let indexPath = IndexPath(row: lastRow, section: 0)
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
    
    func loadMessagesFromCoreData() {
        do {
            try fetchedResultsController.performFetch()
            scrollCellsToBottom(animated: false)
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
    
    func saveLoaded(_ messages: [Message]) {
        Logger.info("=====Процесс обновления сообщений в CoreData запущен=====")
        guard let channelID = currentChannel?.identifier else {
            Logger.error("Отсутствует идентификатор канала")
            return
        }
        
        ChatCoreDataService.shared.performSave { context in
            var messagesDB: [DBMessage] = []
            var currentChannel: DBChannel?
            
            ChatCoreDataService.shared.fetchChannels(from: context) { result in
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
                    $0.created == message.created &&
                    $0.senderName == message.senderName
                }).first == nil else {
                    Logger.info("Сообщение уже есть в базе")
                    return
                }
                
                Logger.info("Найдено новое сообщение")
                ChatCoreDataService.shared.messageSave(
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
        
        if let sections = fetchedResultsController.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MessageCell.identifier,
            for: indexPath
        ) as? MessageCell else { return UITableViewCell() }
        
        let message = fetchedResultsController.object(at: indexPath) as? DBMessage
        
        cell.configureMessageCell(
            senderName: message?.senderName,
            textMessage: message?.content ?? "",
            dateCreated: message?.created ?? Date(),
            isIncoming: message?.senderId != mySenderId
        )
        
        return cell
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

// MARK: - Fetched Results Controller Delegate

extension ChannelViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        channelTableView.beginUpdates()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                channelTableView.insertRows(at: [indexPath], with: .automatic)
                scrollCellsToBottom(animated: true)
            }
        case .delete:
            if let indexPath = indexPath {
                channelTableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath {
                channelTableView.deleteRows(at: [indexPath], with: .automatic)
            }

            if let newIndexPath = newIndexPath {
                channelTableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                let message = fetchedResultsController.object(at: indexPath) as? DBMessage
                let cell = channelTableView.cellForRow(at: indexPath) as? MessageCell
                
                cell?.configureMessageCell(
                    senderName: message?.senderName,
                    textMessage: message?.content ?? "",
                    dateCreated: message?.created ?? Date(),
                    isIncoming: message?.senderId != mySenderId
                )
            }
        @unknown default:
            Logger.error("Что то пошло не так в NSFetchedResultsControllerDelegate")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        channelTableView.endUpdates()
    }
}
