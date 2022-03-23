//
//  ProfileManagerOperation.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 21.03.2022.
//

import Foundation

final class ProfileManagerOperation: AsyncOperation {
    
    enum Operation {
        case loadData
        case saveData
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
    
    private var operation: Operation
    
    var profile: Profile?
    var error: Error?
    
    init(
        _ operation: Operation,
        profile: Profile? = nil,
        name: String? = nil,
        description: String? = nil,
        imageData: Data? = nil
    ) {
        self.operation = operation
        self.profile = profile
        self.profile?.name = name
        self.profile?.description = description
        self.profile?.image = imageData
    }
    
    override func main() {
        if operation == .saveData {
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
                printDebug("Operation: Поиск измененных параметров и их перезапись")
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
                    printDebug("Operation: Имитация сохранения 3 сек")
                    sleep(3)
                    guard let profileDataURL = self?.profileDataURL else { return }
                    
                    do {
                        printDebug("Operation: Запись новых данных")
                        let data = try PropertyListEncoder().encode(savedProfile)
                        try data.write(to: profileDataURL)
                        
                        printDebug("Operation: Данные записаны")
                        completion(nil)
                    } catch {
                        printDebug("Operation: Ошибка записи файла")
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
        printDebug("Operation: Началась загрузка данных")
        
        let addQueue = OperationQueue()
        addQueue.addOperation {
            do {
                // TODO: Удалить ожидание после проверки
                printDebug("Operation: Имитация загрузки 3 сек")
                sleep(3)
                printDebug("Operation: Попытка чтения данных из файла")
                let data = try Data(contentsOf: profileDataURL)
                let profileData = try PropertyListDecoder().decode(Profile.self, from: data)
                
                printDebug("Operation: Файл найден, данные переданы")
                completion(.success(profileData))
                
            } catch {
                printDebug(error)
                printDebug("Operation: Файл не найден")
                
                printDebug("Operation: Создаётся новый профиль")
                let newProfile = Profile()
                
                do {
                    let data = try PropertyListEncoder().encode(newProfile)
                    try data.write(to: profileDataURL)
                    printDebug("Operation: Файл создан")
                    
                    completion(.success(newProfile))
                    printDebug("Operation: Профиль передан")
                } catch {
                    printDebug(error)
                    completion(.failure(error))
                }
            }
        }
    }
}
