//
//  ImageLoadingManager.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 27.04.2022.
//

import UIKit

protocol ImageLoadingManagerProtocol {
    func getImage(from url: String, completion: @escaping (Result<UIImage?, NetworkError>) -> Void)
}

final class ImageLoadingManager: ImageLoadingManagerProtocol {
    private let requestSender: IRequestSenderProtocol
    private var image: UIImage?
    /// Используется для проверки при загрузке ячейки,
    /// чтобы предотвратить загрузку изображения не в ту ячейку
    private var imageUrlString: String = ""
    
    init() {
        requestSender = RequestSender()
    }
    
    func getImage(from url: String, completion: @escaping (Result<UIImage?, NetworkError>) -> Void) {
        imageUrlString = url
        
        guard let urlForCache = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        if let cachedImage = getCachedImage(from: urlForCache) {
            image = cachedImage
            completion(.success(image))
            return
        }
        
        let requestConfig = RequestFactory.PixabayPhotoRequest.imagePixabayConfig(from: url)
        requestSender.send(config: requestConfig) { [weak self] result in
            switch result {
            case .success(let (_, data, response)):
                guard self?.imageUrlString == url else { return }
                guard let data = data else {
                    Logger.error("Ошибка получения данных, возможно в коде")
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    completion(.failure(.noImage))
                    return
                }
                completion(.success(image))
                
                guard let response = response else {
                    Logger.error("Вероятно ошибкаа в коде")
                    return
                }
                self?.saveDataToCache(with: data, response: response)
            case .failure(let error):
                completion(.failure(error))
            }
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
