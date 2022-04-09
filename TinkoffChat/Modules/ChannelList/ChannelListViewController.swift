//
//  ChannelListViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 04.03.2022.
//

import UIKit

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
    
    private let chatCoreDataService = ChatCoreDataService()
    private var channels: [Channel] = []
    private var channelsDB: [DBChannel] = []
    private let activityIndicator = UIActivityIndicatorView()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        fetchDBChannels()
        loadChannels()
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
        
        let count = channels.isEmpty
        ? channelsDB.count
        : channels.count
        
        return count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ChannelCell.self),
            for: indexPath
        ) as? ChannelCell else { return UITableViewCell() }
        
        if channels.isEmpty {
            let channel = channelsDB[indexPath.row]
            
            cell.configure(
                name: channel.name,
                message: channel.lastMessage,
                date: channel.lastActivity,
                online: false,
                hasUnreadMessages: false
            )
        } else {
            let channel = channels[indexPath.row]
            
            cell.configure(
                name: channel.name,
                message: channel.lastMessage,
                date: channel.lastActivity,
                online: false,
                hasUnreadMessages: false
            )
        }
        
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
        
        if channels.isEmpty {
            let channel = channelsDB[indexPath.row]
            
            channelVC.channelID = channel.identifier ?? ""
            channelVC.channelTitle = channel.name
            channelVC.mySenderId = mySenderID
            
        } else {
            let channel = channels[indexPath.row]
            
            channelVC.channelID = channel.identifier
            channelVC.channelTitle = channel.name
            channelVC.mySenderId = mySenderID
        }

        navigationController?.pushViewController(
            channelVC,
            animated: true
        )
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let channel = channels[indexPath.row]
            
            // Это код для очистки каналов после Инны 😀
//            for channel in channels where channel.name == "" {
//                    printDebug("delete ID: \(channel.identifier)")
//                    deleteChannel(id: channel.identifier)
//            }
            
            channels.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            deleteChannel(id: channel.identifier)
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
    
    func loadChannels() {
        activityIndicator.startAnimating()
        
        FirestoreService.shared.fetchChannels { [weak self] result in
            switch result {
            case .success(let channels):
                self?.channels = channels
                // По хорошему, каналы в которых не было активности, нужно добавлять в конец списка, но пока так.
                self?.channels.sort(by: { $0.lastActivity ?? Date() > $1.lastActivity ?? Date() })
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                
                Logger.info("Отображены данные из Firebase")
                
                self?.saveLoaded(channels)
            case .failure(let error):
                Logger.error("\(error.localizedDescription)")
            }
        }
    }
    
    func addNewChannel(name: String) {
        FirestoreService.shared.addNewChannel(name: name)
    }
    
    func deleteChannel(id: String) {
        FirestoreService.shared.deleteChanel(channelID: id)
    }
    
    // MARK: - Core Data Cache
    
    func fetchDBChannels() {
        chatCoreDataService.fetchChannels { [weak self] result in
            switch result {
            case .success(let channelsDB):
                self?.channelsDB = channelsDB
                self?.channelsDB.sort(by: { $0.lastActivity ?? Date() > $1.lastActivity ?? Date() })
                self?.tableView.reloadData()
                
                Logger.info("=====Отображены данные из Core Data=====")
            case .failure(let error):
                Logger.error("\(error.localizedDescription)")
            }
        }
    }
    
    func saveLoaded(_ channels: [Channel]) {
        Logger.info("=====Процесс обновления каналов в CoreData запущен=====")
        chatCoreDataService.performSave { [weak self] context in
            self?.chatCoreDataService.fetchChannels(from: context) { result in
                switch result {
                case .success(let channels):
                    self?.channelsDB = channels
                    
                    Logger.info("Из базы загружено \(channels.count) каналов")
                    
                case .failure(let error):
                    Logger.error("\(error.localizedDescription)")
                }
            }
            
            Logger.info("Запуск процесса проверки каналов на изменение")
            channels.forEach { channel in
                if let channelDB = self?.channelsDB.filter({ $0.identifier == channel.identifier }).first {
                    
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
                    self?.chatCoreDataService.channelSave(channel, context: context)
                }
            }
            
            self?.channelsDB.forEach { channelDB in
                if channels.filter({ $0.identifier == channelDB.identifier }).first == nil {
                    Logger.info("Канал '\(channelDB.name ?? "")' отсутствует на сервере и будет удалён")
                    self?.chatCoreDataService.delete(channelDB, context: context)
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
