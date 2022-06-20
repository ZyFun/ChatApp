//
//  RequestFactory.swift
//  ChatApp
//
//  Created by Дмитрий Данилин on 28.04.2022.
//

import Foundation

struct RequestFactory {
    struct PixabayPhotoRequest {
        static func modelConfig() -> RequestConfig<PixabayParser> {
            let token = TokenProvider.pixabayTokenAPI
            let urlRequest = URLProvider.fetchApiPixabayStringURL(with: token)
            let request = PixabayRequest(urlString: urlRequest)
            let parser = PixabayParser()
            return RequestConfig<PixabayParser>(request: request, parser: parser)
        }
        
        static func imagePixabayConfig(from urlString: String) -> RequestConfig<PixabayParser> {
            let request = PixabayRequest(urlString: urlString)
            return RequestConfig<PixabayParser>(request: request, parser: nil)
        }
    }
}
