//
//  Pixabay.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 28.04.2022.
//

import Foundation

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
