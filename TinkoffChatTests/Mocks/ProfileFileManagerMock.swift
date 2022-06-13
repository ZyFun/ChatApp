//
//  ProfileFileManagerMock.swift
//  TinkoffChatTests
//
//  Created by Дмитрий Данилин on 13.05.2022.
//

import Foundation
@testable import TinkoffChat

final class ProfileFileManagerMock: ProfileFileManagerProtocol {

    var invokedSaveProfileData = false
    var invokedSaveProfileDataCount = 0
    var invokedSaveProfileDataParameters: (name: String?, description: String?, imageData: Data?)?
    var invokedSaveProfileDataParametersList = [(name: String?, description: String?, imageData: Data?)]()
    var stubbedSaveProfileDataCompletionResult: (Result<Void, Error>, Void)?

    func saveProfileData(
        name: String?,
        description: String?,
        imageData: Data?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        invokedSaveProfileData = true
        invokedSaveProfileDataCount += 1
        invokedSaveProfileDataParameters = (name, description, imageData)
        invokedSaveProfileDataParametersList.append((name, description, imageData))
        if let result = stubbedSaveProfileDataCompletionResult {
            completion(result.0)
        }
    }

    var invokedFetchProfileData = false
    var invokedFetchProfileDataCount = 0
    var stubbedFetchProfileDataCompletionResult: (Result<Profile?, Error>, Void)?

    func fetchProfileData(
        completion: @escaping (Result<Profile?, Error>) -> Void
    ) {
        invokedFetchProfileData = true
        invokedFetchProfileDataCount += 1
        if let result = stubbedFetchProfileDataCompletionResult {
            completion(result.0)
        }
    }
}
