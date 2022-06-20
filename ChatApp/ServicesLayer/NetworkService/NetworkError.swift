//
//  NetworkError.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 27.03.2022.
//

enum NetworkError: String, Error {
    case apiError = "Ошибка получения данных с сервера"
    case invalidURL = "⚠️ API Error: Неправильно указан URL."
    case noData = "Попробовать еще раз?"
    case parseError = "Ошибка парсинга данных. Обратитесь к разработчику"
    case networkError = "Ошибка сети. Попробовать загрузить данные еще раз?"
    case statusCodeError = "Ошибка получения кода статуса. Обратитесь к разработчику"
    case serverError = "⚠️ API Error: Сервер недоступен или используется неправильный адрес"
    case manyRequests = "⚠️ API Error: Слишком много запросов, отдохните и повторите позднее."
    case unauthorizedError = "Обратитесь к разработчику"
    case requestError = "⚠️ API Error: Ссылка устарела или произошла ошибка запроса данных"
    case noImage = "⚠️ API Error: По ссылке не найдено изображение"
    case unownedError = "Неизвестная ошибка. До свидания"
}
