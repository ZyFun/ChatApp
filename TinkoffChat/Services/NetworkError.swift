//
//  NetworkError.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 27.03.2022.
//

enum NetworkError: String, Error {
    case apiError = "Ошибка получения данных с сервера"
    case invalidURL = "Неправильно указан URL, обратитесь к разработчику если повторная попытка не даёт результатов. Повторить?"
    case noData = "Попробовать еще раз?"
    case networkError = "Попробовать загрузить данные еще раз?"
    case serverError = "Попробуйте повторить запрос позднее. Повторить сейчас?"
    case manyRequests = "Слишком много запросов, отдохните и повторите позднее."
    case badAPI = "Обратитесь к разработчику"
    case requestError = "Попробуйте повторить позднее. Повторить сейчас?"
    case unownedError = "До свидания"
}
