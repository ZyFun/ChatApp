//
//  FirestoreService.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 27.03.2022.
//

import FirebaseFirestore

final class FirestoreService {
    static let shared = FirestoreService()
    
    private lazy var channels: [Channel] = []
    
    private lazy var db = Firestore.firestore()
    private lazy var reference = db.collection("channels")
    
    func fetchChannels(completion: @escaping (Result<[Channel], Error>) -> Void) {
        reference.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
            }
            
            DispatchQueue.global().async {
                snapshot?.documents.forEach {
                    
                    guard let name = $0["name"] as? String else {
                        return completion(.failure(NetworkError.nameApiError))
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
                    
                    self.channels.append(channel)
                    
                    // TODO: ([27.03.2022]) удалить после тестирования функционала
                    printDebug(channel)
                    
                    DispatchQueue.main.async {
                        completion(.success(self.channels))
                    }
                }
            }
        }
    }
    
    func addNewChannel(name: String) {
        let channel: [String: Any] = [
            "name": name,
            "lastActivity": Timestamp(date: Date())
        ]
        
        DispatchQueue.global().async {
            self.reference.addDocument(data: channel)
        }
    }
}
