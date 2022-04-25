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
    @IBOutlet weak var photoImageView: PhotoImageView!
    
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
            photoImageView.getImage(from: imageURL) { [weak self] in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
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
