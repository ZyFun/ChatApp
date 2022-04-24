//
//  NetworkDataFetcher.swift
//  News
//
//  Created by Дмитрий Данилин on 22.04.2022.
//

import Foundation

final class NetworkDataFetcher {
    static let shared = NetworkDataFetcher()
    
    private init() {}
    
    func fetchJSON<T: Decodable>(dataType: T.Type, urlString: String, response: @escaping (Result<T, NetworkError>) -> Void) {
        NetworkService.shared.request(urlString: urlString) { result in
            switch result {
            case .success(let (data, _)):
                do {
                    let type = try JSONDecoder().decode(T.self, from: data)
                    DispatchQueue.main.async {
                        response(.success(type))
                    }
                } catch let error {
                    Logger.error(error.localizedDescription)
                }
            case .failure(let error):
                Logger.error(error.localizedDescription)
                DispatchQueue.main.async {
                    response(.failure(error))
                }
            }
        }
    }
    
    func fetchPhotoToImageView(from url: URL, response: @escaping (Data, URLResponse) -> Void) {
        let urlString = url.absoluteString
        
        NetworkService.shared.request(urlString: urlString) { result in
            switch result {
            case .success(let(data, urlResponse)):
                guard url == urlResponse.url else { return }
                
                DispatchQueue.main.async {
                    response(data, urlResponse)
                }
            case .failure(let error):
                print("Load image data: \(error)")
            }
        }
    }
}
