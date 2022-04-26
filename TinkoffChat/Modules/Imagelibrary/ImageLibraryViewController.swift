//
//  ImageLibraryViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 22.04.2022.
//

import UIKit

final class ImageLibraryViewController: UIViewController {
    var isOpenForSendMessage = false
    var didSelectLoadedImage: ((_ image: UIImage) -> Void)?
    var didSelectForSendImage: ((_ stringURL: String) -> Void)?
    
    private let requestSender: IRequestSenderProtocol
    
    private var imagesData: [Image] = []
    
    private let itemsPerRow: CGFloat = 3
    private let sectionInserts = UIEdgeInsets(
        top: 10, left: 10, bottom: 10, right: 10
    )
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    init() {
        requestSender = RequestSender()
        super.init(
            nibName: String(describing: ImageLibraryViewController.self),
            bundle: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        getImagesData()
    }
}

private extension ImageLibraryViewController {
    func setup() {
        setupCollectionView()
        registerCell()
    }
    
    func setupCollectionView() {
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
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
                self?.imagesData = imagesData
                DispatchQueue.main.async {
                    self?.imageCollectionView.reloadData()
                }
            case .failure(let error):
                Logger.error(error.rawValue)
            }
        }
    }
}

extension ImageLibraryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesData.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCell.identifier,
            for: indexPath
        ) as? ImageCell else { return UICollectionViewCell() }
        
        let image = imagesData[indexPath.row]
        
        cell.getImage(from: image.webformatURL)
        
        return cell
    }
}

extension ImageLibraryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photoImageVC = PhotoImageView(image: nil)
        let imageData = imagesData[indexPath.row]
        
        guard let imageURL = imageData.webformatURL else { return }
        
        if isOpenForSendMessage {
            didSelectForSendImage?(imageURL)
        } else {
            guard let image = photoImageVC.selectImageToSetInProfile(urlString: imageURL) else { return }
            didSelectLoadedImage?(image)
        }
        dismiss(animated: true)
    }
}

extension ImageLibraryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let paddingWidth = sectionInserts.left * (itemsPerRow + 1)
        let availableWidth = imageCollectionView.frame.width - paddingWidth
        let sizePerItem = availableWidth / itemsPerRow
        return CGSize(width: sizePerItem, height: sizePerItem)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return sectionInserts
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        sectionInserts.left
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        sectionInserts.left
    }
}
