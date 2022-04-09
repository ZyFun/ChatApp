//
//  ChannelListViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 04.03.2022.
//

import UIKit
import CoreData

protocol ThemeDelegate: AnyObject {
    func updateTheme(
        backgroundViewTheme: UIColor,
        backgroundNavBarTheme: UIColor,
        textTheme: UIColor
    )
}

final class ChannelListViewController: UITableViewController {
    // MARK: - Public properties
    
    var mySenderID: String?
    
    // MARK: - Private properties
    
    private let activityIndicator = UIActivityIndicatorView()
    private var fetchedResultsController = ChatCoreDataService.shared.fetchResultController(
        entityName: String(describing: DBChannel.self),
        keyForSort: #keyPath(DBChannel.lastActivity)
    )
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController.delegate = self
        
        setup()
        loadChannelsFromCoreData()
        loadChannelsFromFirebase()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Для проверки работы делегата и замыкания нужно закомментировать. В делегате настроены не все цвета
        setupTheme()
    }
    
    // MARK: - Table view data source
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ChannelCell.self),
            for: indexPath
        ) as? ChannelCell else { return UITableViewCell() }
        
        guard let channel = fetchedResultsController.object(at: indexPath) as? DBChannel else {
            Logger.error("Ошибка каста object к DBChannel")
            return UITableViewCell()
        }
        
        cell.configure(
            name: channel.name,
            message: channel.lastMessage,
            date: channel.lastActivity,
            online: false,
            hasUnreadMessages: false
        )
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        90
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let channelVC = ChannelViewController(
            nibName: String(describing: ChannelViewController.self),
            bundle: nil
        )
        
        let channel = fetchedResultsController.object(at: indexPath) as? DBChannel

        channelVC.channelID = channel?.identifier ?? ""
        channelVC.channelTitle = channel?.name
        channelVC.mySenderId = mySenderID
        
        navigationController?.pushViewController(
            channelVC,
            animated: true
        )
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            guard let channel = fetchedResultsController.object(at: indexPath) as? DBChannel else {
                Logger.error("Ошибка каста object до DBChannel при удалении ячейки")
                return
            }
            
            // Это код для очистки каналов после Инны 😀
//            for channel in channels where channel.name == "" {
//                    printDebug("delete ID: \(channel.identifier)")
//                    deleteFromFirebase(channel)
//            }
            
            deleteFromFirebase(channel)
        }
    }
}

// MARK: - Private methods

private extension ChannelListViewController {
    func setup() {
        setupNavigationBar()
        setupActivityIndicator()
        setupTableView()
    }
    
    func setupTheme() {
        let backgroundViewTheme = UIColor.appColorLoadFor(.backgroundView)
        let backgroundNavBarTheme = UIColor.appColorLoadFor(.backgroundNavBar)
        let textTheme = UIColor.appColorLoadFor(.text)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: textTheme ?? .label]
        appearance.largeTitleTextAttributes = [.foregroundColor: textTheme ?? .label]
        appearance.backgroundColor = backgroundNavBarTheme
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        view.backgroundColor = backgroundViewTheme
    }
    
    // MARK: - Navigation bar setup
    
    func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Channels"
        
        setupNavBarButtons()
    }
    
    func setupNavBarButtons() {
        setupLeftButton()
        setupRightButtons()
    }
    
    // MARK: - NavBar left button
    
    func setupLeftButton() {
        let settingsButton = UIBarButtonItem(
            image: UIImage(named: "SettingsIcon"),
            style: .plain,
            target: self,
            action: #selector(pushThemeVC)
        )
        
        settingsButton.tintColor = .appColorLoadFor(.buttonNavBar)
        
        navigationItem.leftBarButtonItem = settingsButton
    }
    
    @objc func pushThemeVC() {
        let themesVC = ThemesViewController(
            nibName: String(describing: ThemesViewController.self),
            bundle: nil
        )
        
        themesVC.themeDelegate = self
        
        themesVC.completion = { [weak self] viewTheme, navBarTheme, textTheme in
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [.foregroundColor: textTheme]
            appearance.largeTitleTextAttributes = [.foregroundColor: textTheme]
            appearance.backgroundColor = navBarTheme
            
            self?.navigationController?.navigationBar.standardAppearance = appearance
            self?.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            
            self?.view.backgroundColor = viewTheme
            
            // Нужно для того, чтобы поменять цвета в ячейках
            self?.tableView.reloadData()
        }
        
        navigationController?.pushViewController(themesVC, animated: true)
    }
    
    // MARK: - NavBar right buttons
    
    func setupRightButtons() {
        let addChannelButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addChannelButtonPressed)
        )
        
        addChannelButton.tintColor = .appColorLoadFor(.buttonNavBar)
        
        let profileLabel = UILabel(
            frame: CGRect(x: 0, y: 0, width: 40, height: 40)
        )
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(profileButtonPressed)
        )
        
        profileLabel.text = "UN" // TODO: ([27.03.2022]) Сделать выбор букв из имени профиля
        profileLabel.textAlignment = .center
        profileLabel.backgroundColor = .appColorLoadFor(.profileImageView)
        profileLabel.textColor = .appColorLoadFor(.textImageView)
        profileLabel.layer.cornerRadius = profileLabel.frame.height / 2
        profileLabel.layer.masksToBounds = true
        
        profileLabel.isUserInteractionEnabled = true
        profileLabel.addGestureRecognizer(tapGesture)
        
        let profileCustomButton = UIBarButtonItem(customView: profileLabel)
        
        navigationItem.rightBarButtonItems = [profileCustomButton, addChannelButton]
    }
    
    @objc func addChannelButtonPressed() {
        showAlertAddChannel()
    }
    
    @objc func profileButtonPressed() {
        guard let myProfileVC = UIStoryboard(
            name: String(describing: MyProfileViewController.self),
            bundle: nil
        ).instantiateInitialViewController() else { return }
        
        present(myProfileVC, animated: true)
    }
    
    // MARK: - Table View setup
    
    func setupActivityIndicator() {
        activityIndicator.center = view.center
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemGray
    }
    
    func setupTableView() {
        tableView.separatorColor = .appColorLoadFor(.separator)
        setupXibs()
        
        tableView.addSubview(activityIndicator)
    }
    
    /// Инициализация Xibs
    func setupXibs() {
        tableView.register(
            UINib(
                nibName: String(describing: ChannelCell.self),
                bundle: nil
            ),
            forCellReuseIdentifier: String(describing: ChannelCell.self)
        )
    }
    
    // MARK: - Alert Controllers
    
    func showAlertAddChannel() {
        let alert = UIAlertController(
            title: "Новый канал",
            message: "Введите название канала и подтвердите создание",
            preferredStyle: .alert
        )
        
        let addButton = UIAlertAction(
            title: "Создать",
            style: .default
        ) { [weak self] _ in
            guard let channelName = alert.textFields?.first?.text else { return }
            guard !channelName.isEmpty else { return }
            self?.addNewChannel(name: channelName)
        }
        
        let cancelButton = UIAlertAction(title: "Отмена", style: .destructive)
        
        alert.addAction(addButton)
        alert.addAction(cancelButton)
        alert.addTextField { textField in
            textField.placeholder = "Введите название канала"
        }
        
        let currentTheme = ThemeManager.shared.currentTheme
        if currentTheme == Theme.night.rawValue {
            alert.overrideUserInterfaceStyle = .dark
        } else {
            alert.overrideUserInterfaceStyle = .light
        }
        
        present(alert, animated: true)
    }
    
    // MARK: - Firestore request
    
    func loadChannelsFromFirebase() {
        activityIndicator.startAnimating()

        FirestoreService.shared.fetchChannels { [weak self] result in
            switch result {
            case .success(let channels):
                Logger.info("Данные из Firebase загружены")
                self?.saveLoaded(channels)
                self?.activityIndicator.stopAnimating()
            case .failure(let error):
                Logger.error("\(error.localizedDescription)")
            }
        }
    }
    
    func addNewChannel(name: String) {
        FirestoreService.shared.addNewChannel(name: name)
    }
    
    func deleteFromFirebase(_ channel: DBChannel) {
        FirestoreService.shared.deleteChanel(channelID: channel.identifier ?? "")
    }
    
    // MARK: - Core Data Cache
    
    func loadChannelsFromCoreData() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            Logger.error("\(error.localizedDescription)")
        }
    }
    
    func saveLoaded(_ channels: [Channel]) {
        var channelsDB: [DBChannel] = []
        
        Logger.info("=====Процесс обновления каналов в CoreData запущен=====")
        
        ChatCoreDataService.shared.performSave { context in
            ChatCoreDataService.shared.fetchChannels(from: context) { result in
                switch result {
                case .success(let channels):
                    channelsDB = channels
                    Logger.info("Из базы загружено \(channels.count) каналов")
                case .failure(let error):
                    Logger.error("\(error.localizedDescription)")
                }
            }
            
            Logger.info("Запуск процесса проверки каналов на изменение")
            channels.forEach { channel in
                if let channelDB = channelsDB.filter({ $0.identifier == channel.identifier }).first {
                    
                    if channelDB.lastActivity != channel.lastActivity {
                        channelDB.lastActivity = channel.lastActivity
                        
                        Logger.info("Последнее сообщение в канале '\(channel.name)' изменено на: '\(channel.lastMessage ?? "")'")
                    }
                    
                    if channelDB.lastMessage != channel.lastMessage {
                        channelDB.lastMessage = channel.lastMessage
                        
                        Logger.info("Последняя активность канала '\(channel.name)' изменена: '\(String(describing: channel.lastActivity))'")
                    }
                } else {
                    Logger.info("Канал '\(channel.name)' отсутствует в базе и будет добавлен")
                    ChatCoreDataService.shared.channelSave(channel, context: context)
                }
            }
            
            channelsDB.forEach { channelDB in
                if channels.filter({ $0.identifier == channelDB.identifier }).first == nil {
                    Logger.info("Канал '\(channelDB.name ?? "")' отсутствует на сервере и будет удалён")
                    ChatCoreDataService.shared.delete(channelDB, context: context)
                }
            }
        }
    }
}

// MARK: - Theme delegate

extension ChannelListViewController: ThemeDelegate {
    func updateTheme(
        backgroundViewTheme: UIColor,
        backgroundNavBarTheme: UIColor,
        textTheme: UIColor
    ) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: textTheme]
        appearance.largeTitleTextAttributes = [.foregroundColor: textTheme]
        appearance.backgroundColor = backgroundNavBarTheme
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        view.backgroundColor = backgroundViewTheme
    }
}

// MARK: - Fetched Results Controller Delegate

extension ChannelListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
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
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }

            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                let channel = fetchedResultsController.object(at: indexPath) as? DBChannel
                let cell = tableView.cellForRow(at: indexPath) as? ChannelCell
                cell?.configure(
                    name: channel?.name,
                    message: channel?.lastMessage,
                    date: channel?.lastActivity,
                    online: false,
                    hasUnreadMessages: false
                )
            }
        @unknown default:
            Logger.error("Что то пошло не так в NSFetchedResultsControllerDelegate")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
