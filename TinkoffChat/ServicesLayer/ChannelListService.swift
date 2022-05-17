//
//  ChannelListService.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 20.04.2022.
//

protocol ChannelListServiceProtocol {
    func loadChannelsFromFirebase(
        with chatCoreDataService: ChatCoreDataServiceProtocol,
        completion: @escaping () -> Void
    )
    
    func addNewChannel(name: String)
    func deleteFromFirebase(_ channel: DBChannel)
}

class ChannelListService: ChannelListServiceProtocol {
    private var channels: [Channel] = []
    private let chatFirestore: ChatFirestoreProtocol
    
    init() {
        chatFirestore = ChatFirestore()
    }
    
    func loadChannelsFromFirebase(
        with chatCoreDataService: ChatCoreDataServiceProtocol,
        completion: @escaping () -> Void
    ) {
        chatFirestore.fetchChannels { [weak self] result in
            switch result {
            case .success(let channels):
                Logger.info("Данные из Firebase загружены")
                self?.channels = channels
                Logger.info("Сохранение загруженных данных в CoreData")
                self?.saveLoadedChannels(with: chatCoreDataService)
                completion()
            case .failure(let error):
                Logger.error("\(error.localizedDescription)")
            }
        }
    }
    
    func addNewChannel(name: String) {
        chatFirestore.addNewChannel(name: name)
    }
    
    func deleteFromFirebase(_ channel: DBChannel) {
        chatFirestore.deleteChanel(channelID: channel.identifier ?? "")
    }
    
    private func saveLoadedChannels(
        with chatCoreDataService: ChatCoreDataServiceProtocol
    ) {
        var channelsDB: [DBChannel] = []
        
        Logger.info("=====Процесс обновления каналов в CoreData запущен=====")
        chatCoreDataService.performSave { [weak self] context in
            chatCoreDataService.fetchChannels(from: context) { result in
                switch result {
                case .success(let channels):
                    channelsDB = channels
                    Logger.info("Из базы загружено \(channels.count) каналов")
                case .failure(let error):
                    Logger.error("\(error.localizedDescription)")
                }
            }
            
            Logger.info("Запуск процесса проверки каналов на изменение")
            self?.channels.forEach { channel in
                if let channelDB = channelsDB.filter({ $0.identifier == channel.identifier }).first {
                    
                    if channelDB.lastActivity != channel.lastActivity {
                        channelDB.lastActivity = channel.lastActivity
                        Logger.info("Последнее сообщение в канале '\(channel.name)' изменено на: '\(channel.lastMessage ?? "")'")
                    }
                    
                    if channelDB.lastMessage != channel.lastMessage {
                        channelDB.lastMessage = channel.lastMessage
                        Logger.info("Последняя активность канала '\(channel.name)' изменена: '\(String(describing: channel.lastActivity))'")
                    }
                } else {
                    Logger.info("Канал '\(channel.name)' отсутствует в базе и будет добавлен")
                    chatCoreDataService.channelSave(channel, context: context)
                }
            }
            
            channelsDB.forEach { channelDB in
                if self?.channels.filter({ $0.identifier == channelDB.identifier }).first == nil {
                    Logger.info("Канал '\(channelDB.name ?? "")' отсутствует на сервере и будет удалён")
                    chatCoreDataService.delete(channelDB, context: context)
                }
            }
        }
    }
}
