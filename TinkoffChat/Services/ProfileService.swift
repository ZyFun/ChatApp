//
//  ProfileService.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 20.03.2022.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    
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
    
    private init() {}
    
    func saveProfileData(
        name: String?,
        description: String?,
        imageData: Data?,
        completion: @escaping (Error?) -> Void
    ) {
        fetchProfileData { result in
            switch result {
            case .success(var savedProfile):
                printDebug("GCD: Поиск измененных параметров и их перезапись")
                if savedProfile?.name != name {
                    savedProfile?.name = name
                }
                
                if savedProfile?.description != description {
                    savedProfile?.description = description
                }
                
                if savedProfile?.image != imageData {
                    savedProfile?.image = imageData
                }
                
                DispatchQueue.global(qos: .utility).async { [weak self] in
                    // TODO: ([21.03.2022]) Удалить ожидание после проверки
                    printDebug("GCD: Имитация сохранения 3 сек")
                    sleep(3)
                    guard let profileDataURL = self?.profileDataURL else { return }
                    
                    do {
                        printDebug("GCD: Запись новых данных")
                        let data = try PropertyListEncoder().encode(savedProfile)
                        try data.write(to: profileDataURL)
                        
                        DispatchQueue.main.async {
                            printDebug("GCD: Данные записаны")
                            completion(nil)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            printDebug("GCD: Ошибка записи файла")
                            completion(error)
                        }
                    }
                }
            case .failure(let error):
                printDebug(error)
            }
        }
    }
    
    func fetchProfileData(completion: @escaping (Result<Profile?, Error>) -> Void) {
        guard let profileDataURL = profileDataURL else { return }
        printDebug("GCD: Началась загрузка данных")
        
        DispatchQueue.global(qos: .utility).async {
            do {
                // TODO: ([21.03.2022]) Удалить ожидание после проверки
                printDebug("GCD: Имитация загрузки 3 сек")
                sleep(3)
                printDebug("GCD: Попытка чтения данных из файла")
                let data = try Data(contentsOf: profileDataURL)
                let profileData = try PropertyListDecoder().decode(Profile.self, from: data)
                DispatchQueue.main.async {
                    printDebug("GCD: Файл найден, данные переданы")
                    completion(.success(profileData))
                }
            } catch {
                printDebug(error)
                printDebug("GCD: Файл не найден")
                
                // TODO: ([21.03.2022]) Всё ниже сделать отдельным методом, вызываемым из алерта. Например: Ошибка. Профиль не найден, создать новый?
                printDebug("GCD: Создаётся новый профиль")
                let newProfile = Profile()
                
                do {
                    let data = try PropertyListEncoder().encode(newProfile)
                    try data.write(to: profileDataURL)
                    printDebug("GCD: Файл создан")
                    
                    DispatchQueue.main.async {
                        completion(.success(newProfile))
                        printDebug("GCD: Профиль передан")
                    }
                } catch {
                    DispatchQueue.main.async {
                        printDebug(error)
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
