//
//  ImageLibraryViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 22.04.2022.
//

import UIKit

class ImageLibraryViewController: UIViewController {
    private var imagesData: [Image] = []
    
    private let itemsPerRow: CGFloat = 3
    private let sectionInserts = UIEdgeInsets(
        top: 10, left: 10, bottom: 10, right: 10
    )
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        getImages()
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
    
    func getImages() {
        let token = TokenAPI.token.rawValue
        let jsonURL = "https://pixabay.com/api/?key=\(token)&q=yellow&image_type=%20photo&pretty=true&per_page=100"
        
        NetworkDataFetcher.shared.fetchJSON(dataType: ServerInfo.self, urlString: jsonURL) { [weak self] result in
            switch result {
            case .success(let images):
                self?.imagesData = images.hits
                self?.imageCollectionView.reloadData()
            case .failure(let error):
                Logger.error(error.localizedDescription)
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
