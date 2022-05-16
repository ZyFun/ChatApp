//
//  ImageCell.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 22.04.2022.
//

import UIKit

final class ImageCell: UICollectionViewCell {
    static let identifier = String(describing: ImageCell.self)
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    private let imageLoadingManager: ImageLoadingManagerProtocol
        
    required init?(coder: NSCoder) {
        imageLoadingManager = ImageLoadingManager()
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = UIImage(named: "noImage")
    }
    
    func getImage(from imageURL: String?) {
        activityIndicator.startAnimating()
        if let imageURL = imageURL {
            imageLoadingManager.getImage(from: imageURL) { [weak self] result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self?.photoImageView.image = image
                        self?.activityIndicator.stopAnimating()
                    }
                case .failure(let error):
                    Logger.error(error.rawValue)
                }
            }
        } else {
            Logger.warning("Что-то не так с URL")
        }
    }
}

private extension ImageCell {
    func setup() {
        setupActivityIndicator()
        setupImageView()
    }
    
    func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
    }
    
    func setupImageView() {
        photoImageView.backgroundColor = ThemeManager.shared.appColorLoadFor(.profileImageView)
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.image = UIImage(named: "noImage")
    }
}
