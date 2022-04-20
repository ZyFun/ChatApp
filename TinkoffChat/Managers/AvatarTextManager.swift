//
//  AvatarTextManager.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 19.04.2022.
//

protocol AvatarTextManagerProtocol {
    func setFirstCharacters(from fullName: String?) -> String?
    func setFirstCharacter(from channelName: String?) -> String?
}

// TODO: ([20.04.2022]) Аналогичный вопрос по синглтону, имеет ли смысл?
// без него получается так, что много объектов создаётся из-за использования в ячейках
final class AvatarTextManager: AvatarTextManagerProtocol {
    func setFirstCharacters(from fullName: String?) -> String? {
        if let fullName = fullName {
            let separateFullName = fullName.split(separator: " ")
            let numberWords = separateFullName.count
            var characters = ""
            
            if numberWords == 1 {
                guard let firstSymbol = separateFullName.first?.first else { return "UN" }
                return String(firstSymbol)
            } else {
                guard let firstSymbol = separateFullName.first?.first else { return "UN" }
                guard let lastSymbol = separateFullName.last?.first else { return "UN" }
                characters = "\(firstSymbol)\(lastSymbol)"
            }
            
            let bigCharacters = characters.uppercased()
            
            return bigCharacters
        } else {
            return "UN"
        }
    }
    
    func setFirstCharacter(from channelName: String?) -> String? {
        if let channelName = channelName {
            guard let firstSymbol = channelName.first else { return "UN" }
            let bigCharacter = firstSymbol.uppercased()
            
            return bigCharacter
        } else {
            return "UN"
        }
    }
}
