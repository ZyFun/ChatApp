//
//  ChannelListViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 04.03.2022.
//

import UIKit

protocol ChannelListViewControllerDelegate: AnyObject {
    func pushChannelVC(with indexPath: IndexPath)
}

final class ChannelListViewController: UIViewController {
    // MARK: - Public properties
    
    var mySenderID: String?
    
    // MARK: - Private properties
    
    private let assemblyService = AssemblyService()
    private let themeManager: ThemeManagerProtocol
    private let chatCoreDataService: ChatCoreDataServiceProtocol
    private let channelListService: ChannelListServiceProtocol
    private var resultManager: ChannelListFetchedResultsManagerProtocol?
    private var dataSourceManager: ChannelListDataSourceManagerProtocol?
    private let transition: VCAnimator
    
    /// Метод для решения проблемы с ошибкой обновления данных, когда экран не активен.
    private var isAppear = true
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Initializer
    
    init(channelListService: ChannelListServiceProtocol) {
        self.channelListService = channelListService
        themeManager = ThemeManager.shared
        chatCoreDataService = ChatCoreDataService()
        transition = VCAnimator()
        super.init(
            nibName: String(describing: ChannelListViewController.self),
            bundle: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: ([17.04.2022]) не понимаю как сделать более правильный инит и работать через протокол
        // Так как в делегате это сделать не получится, как это сделано с ChannelViewController,
        // там же более подробно описал что у меня не получается сделать.
        // Не понимаю как по другому передать fetchedResultsController и сразу работать с нужным
        resultManager = ChannelListFetchedResultsManager(
            fetchedResultsController: chatCoreDataService.fetchResultController(
                entityName: String(describing: DBChannel.self),
                keyForSort: #keyPath(DBChannel.lastActivity),
                sortAscending: false,
                currentChannel: nil
            )
        )
        
        guard let resultManager = resultManager else {
            Logger.error("Что то не так с resultManager")
            return
        }

        dataSourceManager = ChannelListDataSourceManager(
            resultManager: resultManager,
            channelListService: channelListService
        )
        
        setup()
        activityIndicator.startAnimating()
        channelListService.loadChannelsFromFirebase(
            with: chatCoreDataService
        ) { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTheme()
        
        if !isAppear {
            tableView.reloadData()
            isAppear.toggle()
            resultManager?.isAppear = isAppear
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isAppear.toggle()
        resultManager?.isAppear = isAppear
    }
}

// MARK: - Private methods

private extension ChannelListViewController {
    func setup() {
        setupNavigationBar()
        setupActivityIndicator()
        setupTableView()
        
        resultManager?.tableView = tableView
        dataSourceManager?.channelListViewControllerDelegate = self
    }
    
    func setupTheme() {
        let backgroundViewTheme = themeManager.appColorLoadFor(.backgroundView)
        let backgroundNavBarTheme = themeManager.appColorLoadFor(.backgroundNavBar)
        let textTheme = themeManager.appColorLoadFor(.text)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: textTheme]
        appearance.largeTitleTextAttributes = [.foregroundColor: textTheme]
        appearance.backgroundColor = backgroundNavBarTheme
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        view.backgroundColor = backgroundViewTheme
        tableView.backgroundColor = backgroundViewTheme
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
        
        settingsButton.tintColor = themeManager.appColorLoadFor(.buttonNavBar)
        
        navigationItem.leftBarButtonItem = settingsButton
    }
    
    @objc func pushThemeVC() {
        let themesVC = ThemesViewController()
        
        // TODO: ([18.04.2022]) пересмотреть применение замыкания. С текущей работой с темой это лишнее
        themesVC.completion = { [weak self] in
            guard let self = self else { return }
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [.foregroundColor: self.themeManager.appColorLoadFor(.text)]
            appearance.largeTitleTextAttributes = [.foregroundColor: self.themeManager.appColorLoadFor(.text)]
            appearance.backgroundColor = self.themeManager.appColorLoadFor(.backgroundNavBar)
            
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            
            // Нужно для того, чтобы поменять цвета в ячейках
            self.tableView.reloadData()
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
        
        addChannelButton.tintColor = themeManager.appColorLoadFor(.buttonNavBar)
        
        let profileLabel = UILabel(
            frame: CGRect(x: 0, y: 0, width: 40, height: 40)
        )
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(profileButtonPressed)
        )
        
        profileLabel.text = "UN" // TODO: ([27.03.2022]) Сделать выбор букв из имени профиля
        profileLabel.textAlignment = .center
        profileLabel.backgroundColor = themeManager.appColorLoadFor(.profileImageView)
        profileLabel.textColor = themeManager.appColorLoadFor(.textImageView)
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
        
        // TODO: ([03.05.2022]) Нужно доработать
        // изначально я пытался сделать так, чтобы открывшееся вью скрывалось так же
        // но что то пошло не так и где то я ошибся. Надеюсь найду эту ошибку
        // по этому в текущем варианте лучше выглядит так
//        myProfileVC.modalPresentationStyle = .custom
        myProfileVC.transitioningDelegate = self
        
        present(myProfileVC, animated: true)
    }
    
    // MARK: - Table View setup
    
    func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemGray
    }
    
    func setupTableView() {
        setupXibs()
        tableView.separatorColor = themeManager.appColorLoadFor(.separator)
        tableView.dataSource = dataSourceManager as? UITableViewDataSource
        tableView.delegate = dataSourceManager as? UITableViewDelegate
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
            self?.channelListService.addNewChannel(name: channelName)
        }
        
        let cancelButton = UIAlertAction(title: "Отмена", style: .destructive)
        
        alert.addAction(addButton)
        alert.addAction(cancelButton)
        alert.addTextField { textField in
            textField.placeholder = "Введите название канала"
        }
        
        let currentTheme = themeManager.currentTheme
        if currentTheme == Theme.night.rawValue {
            alert.overrideUserInterfaceStyle = .dark
        } else {
            alert.overrideUserInterfaceStyle = .light
        }
        
        present(alert, animated: true)
    }
}

// MARK: - Navigation delegate

extension ChannelListViewController: ChannelListViewControllerDelegate {
    func pushChannelVC(with indexPath: IndexPath) {
        let channel = resultManager?.fetchedResultsController.object(at: indexPath) as? DBChannel
        
        let channelVC = ChannelViewController(
            messageService: assemblyService.messageService,
            chatCoreDataService: chatCoreDataService,
            resultManager: ChannelFetchedResultsManager(
                fetchedResultsController: chatCoreDataService.fetchResultController(
                    entityName: String(describing: DBMessage.self),
                    keyForSort: #keyPath(DBMessage.created),
                    sortAscending: false,
                    currentChannel: channel
                )
            )
        )
        
        channelVC.mySenderId = mySenderID
        channelVC.currentChannel = channel
        
        navigationController?.pushViewController(
            channelVC,
            animated: true
        )
    }
}

extension ChannelListViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        let buttonView = navigationItem.rightBarButtonItems?.first
        guard let buttonFrame = buttonView?.customView?.frame else { return nil }

        transition.originFrame = buttonFrame
        transition.originFrame = CGRect(
            x: transition.originFrame.origin.x + UIScreen.main.bounds.width - 20,
            y: transition.originFrame.origin.y,
            width: transition.originFrame.size.width - 40,
            height: transition.originFrame.size.height - 40
        )
        
        transition.presenting = true
        
        return transition
    }
    
    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}
