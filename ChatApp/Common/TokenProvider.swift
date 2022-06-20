//
//  TokenProvider.swift
//  ChatApp
//
//  Created by Дмитрий Данилин on 22.04.2022.
//
import Foundation

public struct TokenProvider {
    public static let pixabayTokenAPI = Bundle.main.object(forInfoDictionaryKey: "envToken")
}
