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
                printDebug("Поиск измененных параметров и их перезапись")
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
                    // TODO: Удалить ожидание после проверки
                    printDebug("Имитация сохранения 3 сек")
                    sleep(3)
                    guard let profileDataURL = self?.profileDataURL else { return }
                    
                    do {
                        printDebug("Запись новых данных")
                        let data = try PropertyListEncoder().encode(savedProfile)
                        try data.write(to: profileDataURL)
                        
                        DispatchQueue.main.async {
                            printDebug("Данные записаны")
                            completion(nil)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            printDebug("Ошибка записи файла")
                            completion(error)
                        }
                    }
                }
            case .failure(let error):
                printDebug(error)
            }
        }
    }
    
    // TODO: Сделать получение данных с помощью GCD
    func fetchProfileData(completion: @escaping (Result<Profile?, Error>) -> Void) {
        guard let profileDataURL = profileDataURL else { return }
        printDebug("Началась загрузка данных")
        
        DispatchQueue.global(qos: .utility).async {
            do {
                // TODO: Удалить ожидание после проверки
                printDebug("Имитация загрузки 3 сек")
                sleep(3)
                printDebug("Попытка чтения данных из файла")
                let data = try Data(contentsOf: profileDataURL)
                let profileData = try PropertyListDecoder().decode(Profile.self, from: data)
                DispatchQueue.main.async {
                    printDebug("Файл найден, данные переданы")
                    completion(.success(profileData))
                }
            } catch {
                printDebug(error)
                printDebug("Файл не найден")
                
                // TODO: Всё ниже сделать отдельным методом, вызываемым из алерта. Например: Ошибка. Профиль не найден, создать новый?
                printDebug("Создаётся новый профиль")
                let newProfile = Profile()
                
                do {
                    let data = try PropertyListEncoder().encode(newProfile)
                    try data.write(to: profileDataURL)
                    printDebug("Файл создан")
                    
                    DispatchQueue.main.async {
                        completion(.success(newProfile))
                        printDebug("Профиль передан")
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
