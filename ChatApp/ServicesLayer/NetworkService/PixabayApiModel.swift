//
//  imageItemApiModel.swift
//  ChatApp
//
//  Created by Дмитрий Данилин on 24.04.2022.
//

struct PixabayApiModel: Codable {
    let total: Int?
    let totalHits: Int?
    let hits: [Image]
}

struct Image: Codable {
    let pageURL: String?
    let webformatURL: String?
}
