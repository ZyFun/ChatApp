//
//  FirestoreService.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 27.03.2022.
//

import FirebaseFirestore

final class FirestoreService {
    static let shared = FirestoreService()
    
    private lazy var db = Firestore.firestore()
    private lazy var referenceChannels = db.collection("channels")
    
    private init() {}
    
    // MARK: - Channels
    
    func fetchChannels(completion: @escaping (Result<[Channel], Error>) -> Void) {
        referenceChannels.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
            }
            
            var channels: [Channel] = []
            
            snapshot?.documents.forEach {
                guard let name = $0["name"] as? String else {
                    return completion(.failure(NetworkError.apiError))
                }
                let identifier = $0.documentID
                let lastMessage = $0["lastMessage"] as? String
                let lastActivity = ($0["lastActivity"] as? Timestamp)?.dateValue()
                
                let channel = Channel(
                    identifier: identifier,
                    name: name,
                    lastMessage: lastMessage,
                    lastActivity: lastActivity
                )
                
                channels.append(channel)
                
            }
            
            DispatchQueue.main.async {
                completion(.success(channels))
            }
        }
    }
    
    func addNewChannel(name: String) {
        let channel: [String: Any] = [
            "name": name,
            "lastActivity": FieldValue.serverTimestamp()
        ]
        
        DispatchQueue.global().async { [weak self] in
            self?.referenceChannels.addDocument(data: channel)
        }
    }
    
    func deleteChanel(channelID: String) {
        DispatchQueue.global().async { [weak self] in
            self?.referenceChannels.document(channelID).delete()
        }
    }
    
    // MARK: - Messages
    
    func fetchMessages(
        channelID: String,
        completion: @escaping (Result<[Message], Error>) -> Void
    ) {
        referenceChannels
            .document(channelID)
            .collection("messages")
            .addSnapshotListener { snap, error in
                
                if let error = error {
                    completion(.failure(error))
                }
                
                var messages: [Message] = []
                
                snap?.documents.forEach {
                    // TODO: ([27.03.2022]) расскомментировать после всех тестов, многие не заполняют все свойства. Хотя они должны быть обязательными
                    // и немного доработать убрав лишнее.
//                    guard
                        let content = $0["content"] as? String ?? ""
                        let created = ($0["created"] as? Timestamp)?.dateValue() ?? Date()
                        let senderId = $0["senderId"] as? String ?? ""
                        let senderName = $0["senderName"] as? String ?? ""
                        let messageId = $0.documentID
//                    else {
//                        return completion(.failure(NetworkError.apiError))
//                    }
                    
                    let message = Message(
                        content: content,
                        created: created,
                        senderId: senderId,
                        senderName: senderName,
                        messageId: messageId
                    )
                    
                    messages.append(message)
                }
                
                DispatchQueue.main.async {
                    completion(.success(messages))
                }
            }
    }
    
    func sendMessage(channelID: String, message: String, senderID: String) {
        let message: [String: Any] = [
            "content": message,
            "created": FieldValue.serverTimestamp(),
            "senderId": senderID,
            "senderName": "Дмитрий Данилин" // TODO: ([27.03.2022]) После всех доработок имя будет браться из профиля
        ]
        
        self.referenceChannels.document(channelID).collection("messages").addDocument(data: message)
    }
}
