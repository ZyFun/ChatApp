//
//  DataManagerWithOperation.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 21.03.2022.
//

import Foundation

final class DataManagerWithOperation: AsyncOperation {
    
    enum Action {
        case load
        case save
    }
    
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
    
    private var action: Action
    
    var profile: Profile?
    var error: Error?
    
    init(action: Action, profile: Profile? = nil) {
        self.action = action
        self.profile = profile
    }
    
    override func main() {
        if action == .save {
            saveProfileData(
                name: profile?.name,
                description: profile?.description,
                imageData: profile?.image) { [weak self] error in
                    self?.error = error
                    self?.state = .finished
                }
        } else {
            fetchProfileData { [weak self] result in
                switch result {
                case .success(let profile):
                    self?.profile = profile
                    self?.state = .finished
                case .failure(_):
                    printDebug("Error")
                    self?.state = .finished
                }
            }
        }
    }
    
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
                
                let addQueue = OperationQueue()
                
                addQueue.addOperation { [weak self] in
                    // TODO: Удалить ожидание после проверки
                    printDebug("Имитация сохранения 3 сек")
                    sleep(3)
                    guard let profileDataURL = self?.profileDataURL else { return }
                    
                    do {
                        printDebug("Запись новых данных")
                        let data = try PropertyListEncoder().encode(savedProfile)
                        try data.write(to: profileDataURL)
                        
                        
                        printDebug("Данные записаны")
                        completion(nil)
                        
                    } catch {
                        
                        printDebug("Ошибка записи файла")
                        completion(error)
                        
                    }
                }
            case .failure(let error):
                printDebug(error)
            }
        }
    }
    
    func fetchProfileData(completion: @escaping (Result<Profile?, Error>) -> Void) {
        guard let profileDataURL = profileDataURL else { return }
        printDebug("Началась загрузка данных")
        
        let addQueue = OperationQueue()
        addQueue.addOperation {
            do {
                // TODO: Удалить ожидание после проверки
                printDebug("Имитация загрузки 3 сек")
                sleep(3)
                printDebug("Попытка чтения данных из файла")
                let data = try Data(contentsOf: profileDataURL)
                let profileData = try PropertyListDecoder().decode(Profile.self, from: data)
                
                printDebug("Файл найден, данные переданы")
                completion(.success(profileData))
                
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
                    
                    completion(.success(newProfile))
                    printDebug("Профиль передан")
                    
                } catch {
                    
                    printDebug(error)
                    completion(.failure(error))
                    
                }
            }
        }
    }
}
