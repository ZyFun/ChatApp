//
//  Conversation.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 05.03.2022.
//

import Foundation

struct Conversation {
    let name: String?
    let message: String?
    let date: Date?
    let online: Bool
    let hasUnreadMessages: Bool
    
    static func getConversations() -> [Conversation] {
        [
            Conversation(name: "Королева Таисия",
                         message: "Пробую написать очень длинное предложение чтобы поместилось в несколько строк.",
                         date: Date(),
                         online: true,
                         hasUnreadMessages: true
                        ),
            Conversation(name: "Новикова Яна",
                         message: "Как дела?",
                         date: Date(),
                         online: true,
                         hasUnreadMessages: false
                        ),
            Conversation(name: "Митрофанов Семён",
                         message: "Что происходит?",
                         date: "24.02.2022 18.22".toDate(),
                         online: false,
                         hasUnreadMessages: true
                        ),
            Conversation(name: "Серова Анастасия",
                         message: "Все состояния проверены, если сообщения нет и контакт оффлайн, беседа не отображается",
                         date: "6.03.2022 18.02".toDate(),
                         online: false,
                         hasUnreadMessages: false
                        ),
            Conversation(name: "Оливер Хьюз",
                         message: "Как обучение?",
                         date: Date(),
                         online: false,
                         hasUnreadMessages: true
                        ),
            Conversation(name: "Черкасов Никита",
                         message: nil,
                         date: nil,
                         online: true,
                         hasUnreadMessages: false
                        ),
            Conversation(name: "Романов Матвей",
                         message: "Бессознательные мысли",
                         date: "4.03.2022 18.22".toDate(),
                         online: false,
                         hasUnreadMessages: true
                        ),
            Conversation(name: "Морозова Виктория",
                         message: "Только разобрала ёлку",
                         date: "1.03.2022 18.22".toDate(),
                         online: false,
                         hasUnreadMessages: false
                        ),
            Conversation(name: "Худяков Али",
                         message: "Тинькофф топ!",
                         date: "2.03.2022 18.22".toDate(),
                         online: true,
                         hasUnreadMessages: true
                        ),
            Conversation(name: "Панов Давид",
                         message: "Скоро весна :)",
                         date: "28.02.2022 18.22".toDate(),
                         online: true,
                         hasUnreadMessages: false
                        ),
            Conversation(name: "Фролов Артём",
                         message: "🖖🏻",
                         date: Date(),
                         online: true,
                         hasUnreadMessages: true
                        ),
            Conversation(name: "Алексеева Алиса",
                         message: nil,
                         date: nil,
                         online: true,
                         hasUnreadMessages: false
                        ),
            Conversation(name: "Голованова Ярослава",
                         message: "😁",
                         date: "5.03.2022 18.22".toDate(),
                         online: false,
                         hasUnreadMessages: true
                        ),
            Conversation(name: "Шувалова Амина",
                         message: "🤣🤣🤣",
                         date: "5.03.2022 18.22".toDate(),
                         online: false,
                         hasUnreadMessages: true
                        ),
            Conversation(name: "Алексеева Алёна",
                         message: "Научился делать чат?",
                         date: "10.03.2022 18.22".toDate(),
                         online: true,
                         hasUnreadMessages: true
                        ),
            Conversation(name: "Меркулов Иван",
                         message: nil,
                         date: nil,
                         online: true,
                         hasUnreadMessages: false
                        ),
            Conversation(name: "Воронкова Майя",
                         message: "Пополнение электронного кошелька",
                         date: "5.03.2022 18.22".toDate(),
                         online: false,
                         hasUnreadMessages: true
                        ),
            Conversation(name: "Сидоров Иван",
                         message: "Огонь ведь не бывает сам по себе, он не берется ниоткуда...",
                         date: "12.01.2022 18.22".toDate(),
                         online: false,
                         hasUnreadMessages: true
                        ),
            Conversation(name: "Морозова Майя",
                         message: "С новым годом!!!",
                         date: "1.01.2022 18.22".toDate(),
                         online: true,
                         hasUnreadMessages: false
                        ),
            Conversation(name: "Мельников Давид",
                         message: "Жизнь надо любить",
                         date: "5.03.2022 18.22".toDate(),
                         online: false,
                         hasUnreadMessages: true
                        ),
            
        
        ]
    }
    
}
