//
//  ProfileService.swift
//  ChatApp
//
//  Created by Дмитрий Данилин on 21.04.2022.
//

import Foundation

protocol ProfileServiceProtocol {
    func saveProfile(
        name: String?,
        description: String?,
        imageData: Data?,
        completion: @escaping (Result<Profile?, Error>) -> Void
    )
    
    func loadProfile(completion: @escaping (Result<Profile?, Error>) -> Void)
}

final class ProfileService: ProfileServiceProtocol {
    private let profileFileManager: ProfileFileManagerProtocol
    private var profile: Profile?
    
    init(profileFileManager: ProfileFileManagerProtocol) {
        self.profileFileManager = profileFileManager
    }
    
    func saveProfile(
        name: String?,
        description: String?,
        imageData: Data?,
        completion: @escaping (Result<Profile?, Error>) -> Void
    ) {
        profileFileManager.saveProfileData(
            name: name,
            description: description,
            imageData: imageData
        ) { [weak self] result in
            switch result {
            case .success(let swiftlint):
                // TODO: ([11.04.2022]) swiftlint не даёт оставить пустым, хотя мне не нужно отсюда ничего.
                Logger.info("\(swiftlint)", showInConsole: false)
                self?.profile?.image = imageData
                self?.profile?.name = name
                self?.profile?.description = description
                completion(.success(self?.profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loadProfile(completion: @escaping (Result<Profile?, Error>) -> Void) {
        profileFileManager.fetchProfileData { [weak self] result in
            switch result {
            case .success(let savedProfile):
                self?.profile = savedProfile
                completion(.success(self?.profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
