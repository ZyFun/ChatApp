//
//  URLProvider.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 24.04.2022.
//

import Foundation

public struct URLProvider: IRequestProtocol {
    var urlRequest: URLRequest?
    
    public static func fetchApiPixabayStringURL(with token: String) -> String {
        let urlString = "https://pixabay.com/api/?key=\(token)&q=yellow&image_type=%20photo&pretty=true&per_page=100"
        
        return urlString
    }
}
