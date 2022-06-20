//
//  ProfileModel.swift
//  ChatApp
//
//  Created by Дмитрий Данилин on 19.03.2022.
//

import Foundation

struct Profile: Codable {
    var name: String?
    var description: String?
    var image: Data?
}
