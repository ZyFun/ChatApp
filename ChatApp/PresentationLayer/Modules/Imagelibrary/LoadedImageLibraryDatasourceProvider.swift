//
//  LoadedImageLibraryDatasourceProvider.swift
//  ChatApp
//
//  Created by Дмитрий Данилин on 26.04.2022.
//

import UIKit

protocol LoadedImageLibraryDatasourceProviderProtocol {
    var collectionView: UICollectionView { get set }
    var isOpenForSendMessage: Bool? { get set }
    var didSelectLoadedImage: ((_ image: UIImage) -> Void)? { get set }
    var didSelectForSendImage: ((_ stringURL: String) -> Void)? { get set }
    var imagesData: [Image]? { get set }
    
}

final class LoadedImageLibraryDatasourceProvider: NSObject, LoadedImageLibraryDatasourceProviderProtocol {
    var collectionView: UICollectionView
    var isOpenForSendMessage: Bool?
    var imagesData: [Image]?
    var didSelectLoadedImage: ((_ image: UIImage) -> Void)?
    var didSelectForSendImage: ((_ stringURL: String) -> Void)?
    
    private let cacheManager: ImageLoadingManagerProtocol
    private let itemsPerRow: CGFloat = 3
    private let sectionInserts = UIEdgeInsets(
        top: 10, left: 10, bottom: 10, right: 10
    )
    
    init(
        collectionView: UICollectionView
    ) {
        cacheManager = ImageLoadingManager()
        self.collectionView = collectionView
        
        super.init()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
}

// MARK: - Collection view data source

extension LoadedImageLibraryDatasourceProvider: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesData?.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCell.identifier,
            for: indexPath
        ) as? ImageCell else { return UICollectionViewCell() }
        
        let image = imagesData?[indexPath.row]
        
        cell.getImage(from: image?.webformatURL)
        
        return cell
    }
}

// MARK: - Collection view delegate

extension LoadedImageLibraryDatasourceProvider: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let imageData = imagesData?[indexPath.row]
        
        guard let imageURL = imageData?.webformatURL else { return }
        
        if isOpenForSendMessage ?? false {
            didSelectForSendImage?(imageURL)
        } else {
            cacheManager.getImage(from: imageURL) { [weak self] result in
                switch result {
                case .success(let image):
                    guard let image = image else { return }
                    self?.didSelectLoadedImage?(image)
                case .failure(let error):
                    Logger.error(error.rawValue)
                }
            }
        }
    }
}

// MARK: - Collection view delegate flow layout

extension LoadedImageLibraryDatasourceProvider: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let paddingWidth = sectionInserts.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingWidth
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
