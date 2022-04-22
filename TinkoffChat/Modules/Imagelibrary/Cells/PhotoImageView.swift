//
//  PhotoImageView.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 22.04.2022.
//

import UIKit

class PhotoImageView: UIImageView {
    func getImage(from url: String, completion: @escaping () -> Void) {
        guard let url = URL(string: url) else {
            image = UIImage(named: "noImage")
            completion()
            return
        }
        
        if let cachedImage = getCachedImage(from: url) {
            image = cachedImage
            completion()
            return
        }
        
        NetworkDataFetcher.shared.fetchPhotoToImageView(from: url) { [weak self] data, response in
            self?.image = UIImage(data: data)
            self?.saveDataToCache(with: data, response: response)
            completion()
        }
    }
    
    private func saveDataToCache(with data: Data, response: URLResponse) {
        guard let url = response.url else { return }
        let urlRequest = URLRequest(url: url)
        let cachedResponse = CachedURLResponse(response: response, data: data)
        URLCache.shared.storeCachedResponse(cachedResponse, for: urlRequest)
    }
    
    private func getCachedImage(from url: URL) -> UIImage? {
        let request = URLRequest(url: url)
        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            return UIImage(data: cachedResponse.data)
        }
        
        return nil
    }
}
