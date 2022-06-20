//
//  RequestService.swift
//  ChatApp
//
//  Created by Дмитрий Данилин on 24.04.2022.
//

import Foundation

protocol IRequestProtocol {
    var urlRequest: URLRequest? { get }
}

protocol IParserProtocol {
    associatedtype Model
    func parse(data: Data) -> Model?
}

protocol IRequestSenderProtocol {
    func send<Parser>(
        config: RequestConfig<Parser>,
        completionHandler: @escaping (Result<(Parser.Model?, Data?, URLResponse?), NetworkError>) -> Void
    )
}

struct RequestConfig<Parser> where Parser: IParserProtocol {
    let request: IRequestProtocol
    let parser: Parser?
}

class RequestSender: IRequestSenderProtocol {
    func send<Parser>(
        config: RequestConfig<Parser>,
        completionHandler: @escaping (Result<(Parser.Model?, Data?, URLResponse?), NetworkError>) -> Void
    ) where Parser: IParserProtocol {
        guard let urlRequest = config.request.urlRequest else {
            completionHandler(.failure(.invalidURL))
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                Logger.error(error.localizedDescription)
                completionHandler(.failure(.networkError))
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                Logger.error("Ошибка получения кода статуса")
                completionHandler(.failure(.statusCodeError))
                return
            }
            
            if !(200..<300).contains(statusCode) {
                switch statusCode {
                case 400:
                    completionHandler(.failure(.requestError))
                case 401:
                    completionHandler(.failure(.unauthorizedError))
                case 429:
                    completionHandler(.failure(.manyRequests))
                case 500...:
                    completionHandler(.failure(.serverError))
                default:
                    completionHandler(.failure(.unownedError))
                    Logger.error(statusCode.description)
                }
            }
            
            if let data = data,
               let parseModel: Parser.Model = config.parser?.parse(data: data) {
                completionHandler(.success((parseModel, nil, nil)))
            } else if let data = data {
                completionHandler(.success((nil, data, response)))
            } else {
                completionHandler(.failure(.parseError))
            }
        }
        task.resume()
    }
}
