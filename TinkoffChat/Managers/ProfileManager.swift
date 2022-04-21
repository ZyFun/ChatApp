//
//  ProfileManager.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 21.04.2022.
//

import Foundation

protocol ProfileManagerProtocol {
    func saveProfile(
        name: String?,
        description: String?,
        imageData: Data?,
        completion: @escaping (Result<Profile?, Error>) -> Void
    )
    
    func loadProfile(completion: @escaping (Result<Profile?, Error>) -> Void)
}

final class ProfileManager: ProfileManagerProtocol {
    private let profileService: ProfileServiceProtocol
    private var profile: Profile?
    
    init() {
        profileService = ProfileService()
    }
    
    func saveProfile(
        name: String?,
        description: String?,
        imageData: Data?,
        completion: @escaping (Result<Profile?, Error>) -> Void
    ) {
        profileService.saveProfileData(
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
        profileService.fetchProfileData { [weak self] result in
            switch result {
            case .success(let savedProfile):
                self?.profile = savedProfile
                completion(.success(self?.profile))
            case .failure(let error):
                completion(.failure(error))
                printDebug("Что то пошло не так: \(error)")
                // TODO: ([21.03.2022]) Нужен будет алерт о том, что данные не получены
            }
        }
    }
}
