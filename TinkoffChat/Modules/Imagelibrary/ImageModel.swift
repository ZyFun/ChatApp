//
//  ImageModel.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 22.04.2022.
//

struct ServerInfo: Decodable {
    let total: Int?
    let totalHits: Int?
    let hits: [Image]
}

struct Image: Codable {
    let pageURL: String?
    let webformatURL: String?
}
