//
//  DataManagerWithGCD.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 20.03.2022.
//

import Foundation

class DataManagerWithGCD {
    static let shared = DataManagerWithGCD()
    
    private var documentDirectory = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first
    
    private var profileDataURL: URL? {
        if let documentDirectory = documentDirectory {
            return documentDirectory
                .appendingPathComponent("Profile")
                .appendingPathExtension("plist")
        }
        
        return nil
    }
    
    private init(){}
    
    func saveProfileData(
        name: String?,
        description: String?,
        imageData: Data?,
        completion: @escaping (Error?) -> Void
    ) {
        fetchProfileData { result in
            switch result {
            case .success(var savedProfile):
                if savedProfile?.name != name {
                    savedProfile?.name = name
                }
                
                if savedProfile?.description != description {
                    savedProfile?.description = description
                }
                
                if savedProfile?.image != imageData {
                    savedProfile?.image = imageData
                }
                
                // TODO: Удалить ожидание после проверки
                DispatchQueue.global().asyncAfter(deadline: .now() + 3) { [weak self] in
                    guard let profileDataURL = self?.profileDataURL else { return }
                    
                    do {
                        let data = try PropertyListEncoder().encode(savedProfile)
                        try data.write(to: profileDataURL)
                        
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(error)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // TODO: Сделать получение данных с помощью GCD
    func fetchProfileData(completion: @escaping (Result<Profile?, Error>) -> Void) {
        guard let profileDataURL = profileDataURL else { return }
        
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: profileDataURL)
                let profileData = try PropertyListDecoder().decode(Profile.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(profileData))
                }
            } catch {
                print(error)
                
                print("Создаётся новый профиль")
                let newProfile = Profile()
                
                DispatchQueue.global().async { [weak self] in
                    guard let profileDataURL = self?.profileDataURL else { return }
                    
                    do {
                        let data = try PropertyListEncoder().encode(newProfile)
                        try data.write(to: profileDataURL)
                        
                        DispatchQueue.main.async {
                            completion(.success(newProfile))
                        }
                    } catch {
                        DispatchQueue.main.async {
                            print(error)
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }
}
