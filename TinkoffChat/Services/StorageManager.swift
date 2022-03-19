//
//  StorageManager.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 14.03.2022.
//

import Foundation

final class StorageManager {
    enum Key: String {
        case theme
    }
    
    static let shared = StorageManager()
    // Есть вопрос по синглтону. Когда выполнял задание для поступления в школу,
    // в обратной связи мне написали:
    // "А зачем? Можно же инитить по необходимости"
    // Я долго пытался разобраться что я сделал не так, но у меня так и не получилось.
    // Всё было написано +- тоже самое. Мне нужна более подробная подсказка куда копать ))
    
    private let userDefaults = UserDefaults()
    
    // TODO: Сделать нормальное извлечение опционала
    private var documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let profileDataURL: URL
    
    private init(){
        profileDataURL = documentDirectory.appendingPathComponent("Profile").appendingPathExtension("plist")
    }
    
    // TODO: Перенести логику в другие классы, как это описано в ДЗ
    // MARK: Profile
    // TODO: Написать клоужером, чтобы останавливать и запускать активити индикатор и отображать алерты
    func saveProfileData(name: String?, describing: String?, imageData: Data?) {
        var savedProfile = fetchProfileData()
        
        // TODO: Сделать проверку файлов, чтобы не производить перезапись свойства, если данные не менялись
        savedProfile.name = name
        savedProfile.description = describing
        savedProfile.image = imageData
        
        // TODO: Переписать с обраьоткой ошибок
        guard let data = try? PropertyListEncoder().encode(savedProfile) else { return }
        try? data.write(to: profileDataURL)
    }
    
    func fetchProfileData() -> Profile {
        guard let data = try? Data(contentsOf: profileDataURL) else { return Profile() }
        guard let profileData = try? PropertyListDecoder().decode(Profile.self, from: data) else { return Profile() }
        
        return profileData
    }
    
    // MARK: Theme
    func saveTheme(theme: Theme) {
        userDefaults.set(theme.rawValue, forKey: StorageManager.Key.theme.rawValue)
        
        // TODO: Не уверен что это должно быть тут
        ThemeManager.shared.currentTheme = theme.rawValue
    }
    
    func loadTheme(withKey: StorageManager.Key) -> String {
        userDefaults.string(forKey: withKey.rawValue) ?? ""
    }
}
