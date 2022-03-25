//
//  Channel.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 05.03.2022.
//

import Foundation

struct Channel {
    let name: String?
    let message: String?
    let date: Date?
    let online: Bool
    let hasUnreadMessages: Bool
    
    static func getChannels() -> [Channel] {
        [
            Channel(name: "Королева Таисия",
                         message: "Пробую написать очень длинное предложение чтобы поместилось в несколько строк.",
                         date: Date(),
                         online: true,
                         hasUnreadMessages: true
                        ),
            Channel(name: "Новикова Яна",
                         message: "Как дела?",
                         date: Date(),
                         online: true,
                         hasUnreadMessages: false
                        ),
            Channel(name: "Митрофанов Семён",
                         message: "Что происходит?",
                         date: "24.02.2022 18.22".toDate(),
                         online: false,
                         hasUnreadMessages: true
                        ),
            Channel(name: "Серова Анастасия",
                         message: "Все состояния проверены, если сообщения нет и контакт оффлайн, беседа не отображается",
                         date: "6.03.2022 18.02".toDate(),
                         online: false,
                         hasUnreadMessages: false
                        ),
            Channel(name: "Оливер Хьюз",
                         message: "Как обучение?",
                         date: Date(),
                         online: false,
                         hasUnreadMessages: true
                        ),
            Channel(name: "Черкасов Никита",
                         message: nil,
                         date: nil,
                         online: true,
                         hasUnreadMessages: false
                        ),
            Channel(name: "Романов Матвей",
                         message: "Бессознательные мысли",
                         date: "4.03.2022 18.22".toDate(),
                         online: false,
                         hasUnreadMessages: true
                        ),
            Channel(name: "Морозова Виктория",
                         message: "Только разобрала ёлку",
                         date: "1.03.2022 18.22".toDate(),
                         online: false,
                         hasUnreadMessages: false
                        ),
            Channel(name: "Худяков Али",
                         message: "Тинькофф топ!",
                         date: "2.03.2022 18.22".toDate(),
                         online: true,
                         hasUnreadMessages: true
                        ),
            Channel(name: "Панов Давид",
                         message: "Скоро весна :)",
                         date: "28.02.2022 18.22".toDate(),
                         online: true,
                         hasUnreadMessages: false
                        ),
            Channel(name: "Фролов Артём",
                         message: "🖖🏻",
                         date: Date(),
                         online: true,
                         hasUnreadMessages: true
                        ),
            Channel(name: "Алексеева Алиса",
                         message: nil,
                         date: nil,
                         online: true,
                         hasUnreadMessages: false
                        ),
            Channel(name: "Голованова Ярослава",
                         message: "😁",
                         date: "5.03.2022 18.22".toDate(),
                         online: false,
                         hasUnreadMessages: true
                        ),
            Channel(name: "Шувалова Амина",
                         message: "🤣🤣🤣",
                         date: "5.03.2022 18.22".toDate(),
                         online: false,
                         hasUnreadMessages: true
                        ),
            Channel(name: "Алексеева Алёна",
                         message: "Научился делать чат?",
                         date: "10.03.2022 18.22".toDate(),
                         online: true,
                         hasUnreadMessages: true
                        ),
            Channel(name: "Меркулов Иван",
                         message: nil,
                         date: nil,
                         online: true,
                         hasUnreadMessages: false
                        ),
            Channel(name: "Воронкова Майя",
                         message: "Пополнение электронного кошелька",
                         date: "5.03.2022 18.22".toDate(),
                         online: false,
                         hasUnreadMessages: true
                        ),
            Channel(name: "Сидоров Иван",
                         message: "Огонь ведь не бывает сам по себе, он не берется ниоткуда...",
                         date: "12.01.2022 18.22".toDate(),
                         online: false,
                         hasUnreadMessages: true
                        ),
            Channel(name: "Морозова Майя",
                         message: "С новым годом!!!",
                         date: "1.01.2022 18.22".toDate(),
                         online: true,
                         hasUnreadMessages: false
                        ),
            Channel(name: "Мельников Давид",
                         message: "Жизнь надо любить",
                         date: "5.03.2022 18.22".toDate(),
                         online: false,
                         hasUnreadMessages: true
                        ),
        ]
    }
    
}
