//
//  ImageCell.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 22.04.2022.
//

import UIKit

class ImageCell: UICollectionViewCell {
    static let identifier = String(describing: ImageCell.self)
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photoImageView: PhotoImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
        
        backgroundColor = ThemeManager.shared.appColorLoadFor(.profileImageView)
        photoImageView.contentMode = .scaleAspectFill
    }
    
    func configure(image: UIImage) {
        photoImageView.image = image
    }
    
    func getImage(from imageURL: String?) {
        if let imageURL = imageURL {
            photoImageView.getImage(from: imageURL) { [weak self] in
                self?.activityIndicator.stopAnimating()
            }
        } else {
            Logger.warning("Что то не так с фотографией")
        }
    }
}

private extension ImageCell {
    func setup() {
        setupActivityIndicator()
    }
    
    func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
}
