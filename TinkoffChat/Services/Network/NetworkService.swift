//
//  NetworkService.swift
//  News
//
//  Created by Дмитрий Данилин on 22.04.2022.
//

import Foundation

final class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    func request(urlString: String, completion: @escaping (Result<(Data, URLResponse), NetworkError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
             
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                completion(.failure(.networkError))
                return
            }
                        
            if !(200..<300).contains(statusCode) {
                switch statusCode {
                case 400:
                    completion(.failure(.requestError))
                case 401:
                    completion(.failure(.unauthorizedError))
                case 429:
                    completion(.failure(.manyRequests))
                case 500...:
                    completion(.failure(.serverError))
                default:
                    completion(.failure(.unownedError))
                    Logger.error(statusCode.description)
                }
            }
            
            guard let response = response else { return }
            
            if let data = data,
               error == nil {
                
                completion(.success((data, response)))
                
            } else {
                guard let error = error else { return }
                completion(.failure(.noData))
                Logger.error(error.localizedDescription)
                return
            }
            
        }.resume()
    }
}
