//
//  LoadedImageLibraryViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 22.04.2022.
//

import UIKit

final class LoadedImageLibraryViewController: UIViewController {
    var dataSourceProvider: LoadedImageLibraryDatasourceProviderProtocol?
    var isOpenForSendMessage: Bool?
    private let requestSender: IRequestSenderProtocol
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    init() {
        requestSender = RequestSender()
        super.init(
            nibName: String(describing: LoadedImageLibraryViewController.self),
            bundle: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        
        // TODO: ([28.04.2022]) предыдущее ДЗ не проверено и я всё еще не понимаю как делать более правильно :(
        dataSourceProvider = LoadedImageLibraryDatasourceProvider(
            collectionView: imageCollectionView
        )
        dataSourceProvider?.isOpenForSendMessage = isOpenForSendMessage
        
        getImagesData()
    }
}

private extension LoadedImageLibraryViewController {
    func setup() {
        setupCollectionView()
        registerCell()
    }
    
    func setupCollectionView() {
        imageCollectionView.backgroundColor = ThemeManager.shared.appColorLoadFor(.backgroundView)
    }
    
    func registerCell() {
        imageCollectionView.register(
            UINib(
                nibName: String(describing: ImageCell.self),
                bundle: nil
            ),
            forCellWithReuseIdentifier: ImageCell.identifier
        )
    }
    
    func getImagesData() {
        let requestConfig = RequestFactory.PixabayPhotoRequest.modelConfig()
        requestSender.send(config: requestConfig) { [weak self] result in
            switch result {
            case .success(let (model, _, _)):
                guard let imagesData = model?.hits else { return }
                self?.dataSourceProvider?.imagesData = imagesData
                DispatchQueue.main.async {
                    self?.imageCollectionView.reloadData()
                }
            case .failure(let error):
                Logger.error(error.rawValue)
            }
        }
    }
}
