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
        var savedProfile = fetchProfileData()
        
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
    }
    
    // TODO: Сделать получение данных с помощью GCD
    func fetchProfileData() -> Profile? {
        guard let profileDataURL = profileDataURL else { return nil}

        guard let data = try? Data(contentsOf: profileDataURL) else { return Profile() }
        guard let profileData = try? PropertyListDecoder().decode(Profile.self, from: data) else { return Profile() }

        return profileData
    }
}
