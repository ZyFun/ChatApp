//
//  NetworkService.swift
//  TinkoffChat
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
        completionHandler: @escaping (Result<Parser.Model, NetworkError>) -> Void
    )
}

struct RequestConfig<Parser> where Parser: IParserProtocol {
    let request: IRequestProtocol
    let parser: Parser
}

class PixabayParser: IParserProtocol {
    typealias Model = PixabayApiModel
    
    func parse(data: Data) -> Model? {
        var model: Model?
        do {
            model = try JSONDecoder().decode(Model.self, from: data)
        } catch {
            Logger.error(error.localizedDescription)
        }
        return model
    }
}

class RequestSender: IRequestSenderProtocol {
    func send<Parser>(
        config: RequestConfig<Parser>,
        completionHandler: @escaping (Result<Parser.Model, NetworkError>) -> Void
    ) where Parser : IParserProtocol {
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
            
            guard
                let data = data,
                let parseModel: Parser.Model = config.parser.parse(data: data) else {
                completionHandler(.failure(.parseError))
                return
            }
            completionHandler(.success(parseModel))
        }
        task.resume()
    }
}

struct PixabayRequest: IRequestProtocol {
    var urlRequest: URLRequest?
    var urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
        urlRequest = request(stringURL: urlString)
    }
    
    mutating func request(stringURL: String) -> URLRequest? {
        if let url = URL(string: stringURL) {
            urlRequest = URLRequest(url: url, timeoutInterval: 30)
        } else {
            Logger.error("Неправильный URL")
        }
        return urlRequest
    }
}

struct RequestFactory {
    struct PhotoRequest {
        static func modelConfig() -> RequestConfig<PixabayParser> {
            let token = TokenProvider.pixabayTokenAPI
            let urlRequest = URLProvider.fetchApiPixabayStringURL(with: token)
            let request = PixabayRequest(urlString: urlRequest)
            let parser = PixabayParser()
            return RequestConfig<PixabayParser>(request: request, parser: parser)
        }
    }
}
