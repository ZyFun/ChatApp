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
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        fetchProfileData { result in
            switch result {
            case .success(var savedProfile):
                Logger.info("GCD: Поиск измененных параметров и их перезапись")
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
                    Logger.info("GCD: Имитация сохранения 3 сек")
                    sleep(3)
                    guard let profileDataURL = self?.profileDataURL else { return }
                    
                    do {
                        Logger.info("GCD: Запись новых данных")
                        let data = try PropertyListEncoder().encode(savedProfile)
                        try data.write(to: profileDataURL)
                        
                        completion(.success(()))
                        Logger.info("GCD: Данные записаны")
                    } catch {
                        completion(.failure(error))
                        Logger.error(error.localizedDescription)
                    }
                }
            case .failure(let error):
                completion(.failure(error))
                Logger.error(error.localizedDescription)
            }
        }
    }
    
    func fetchProfileData(completion: @escaping (Result<Profile?, Error>) -> Void) {
        guard let profileDataURL = profileDataURL else { return }
        Logger.info("GCD: Началась загрузка данных")
        
        DispatchQueue.global(qos: .utility).async {
            do {
                // TODO: ([21.03.2022]) Удалить ожидание после проверки
                Logger.info("GCD: Имитация загрузки 3 сек")
                sleep(3)
                Logger.info("GCD: Попытка чтения данных из файла")
                let data = try Data(contentsOf: profileDataURL)
                let profileData = try PropertyListDecoder().decode(Profile.self, from: data)
                
                completion(.success(profileData))
                Logger.info("GCD: Файл найден, данные переданы")
            } catch {
                Logger.warning(error.localizedDescription)
                
                // TODO: ([21.03.2022]) Всё ниже сделать отдельным методом, вызываемым из алерта. Например: Ошибка. Профиль не найден, создать новый?
                Logger.info("GCD: Создаётся новый профиль")
                let newProfile = Profile()
                
                do {
                    let data = try PropertyListEncoder().encode(newProfile)
                    try data.write(to: profileDataURL)
                    Logger.info("GCD: Файл создан")
                    
                    completion(.success(newProfile))
                    Logger.info("GCD: Профиль передан")
                } catch {
                    completion(.failure(error))
                    Logger.error(error.localizedDescription)
                }
            }
        }
    }
}
