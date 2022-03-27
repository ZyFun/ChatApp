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
    
    // MARK: - Private properties
    
    private var channels: [Channel] = []
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        fetchChannels()
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
        
        channels.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ChannelCell.self),
            for: indexPath
        ) as? ChannelCell else { return UITableViewCell() }
        
        let channel = channels[indexPath.row]
        
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
        
        let channel = channels[indexPath.row]
        
        channelVC.channelID = channel.identifier
        channelVC.channelTitle = channel.name
        
        navigationController?.pushViewController(
            channelVC,
            animated: true
        )
        
//        FirestoreService.shared.sendMessage(
//            channelID: channel.identifier,
//            message: "🖖🏻",
//            senderID: "ZyFun"
//        )
    }
}

// MARK: - Private methods

private extension ChannelListViewController {
    func setup() {
        setupNavigationBar()
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
    
    func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Channels"
        
        setupNavBarButtons()
    }
    
    func setupNavBarButtons() {
        setupSettingsButton()
        setupProfileButton()
    }
    
    func setupSettingsButton() {
        let barButton = UIBarButtonItem(
            image: UIImage(named: "SettingsIcon"),
            style: .plain,
            target: self,
            action: #selector(pushThemeVC)
        )
        
        barButton.tintColor = .appColorLoadFor(.buttonNavBar)
        
        navigationItem.leftBarButtonItem = barButton
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
    
    func setupProfileButton() {
        let profileButton = UILabel(
            frame: CGRect(x: 0, y: 0, width: 40, height: 40)
        )
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(profileButtonPressed)
        )
        
        profileButton.text = "UN" // TODO: ([27.03.2022]) Сделать выбор букв из названия канала
        profileButton.textAlignment = .center
        profileButton.backgroundColor = .appColorLoadFor(.profileImageView)
        profileButton.textColor = .appColorLoadFor(.textImageView)
        profileButton.layer.cornerRadius = profileButton.frame.height / 2
        profileButton.layer.masksToBounds = true
        
        profileButton.isUserInteractionEnabled = true
        profileButton.addGestureRecognizer(tapGesture)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: profileButton
        )
    }
    
    @objc func profileButtonPressed() {
         guard let myProfileVC = UIStoryboard(
            name: String(describing: MyProfileViewController.self),
            bundle: nil
         ).instantiateInitialViewController() else { return }
        
        present(myProfileVC, animated: true)
    }
    
    func setupTableView() {
        tableView.separatorColor = .appColorLoadFor(.separator)
        setupXibs()
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
    
    // MARK: - Firestore request
    
    // TODO: ([27.03.2022]) Добавить активити индикатор, пока грузятся каналы.
    func fetchChannels() {
        FirestoreService.shared.fetchChannels { [weak self] result in
            switch result {
            case .success(let channels):
                self?.channels = channels
                self?.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addNewChannel(name: String) {
        FirestoreService.shared.addNewChannel(name: name)
        
        // Обновляю список каналов
        fetchChannels()
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
