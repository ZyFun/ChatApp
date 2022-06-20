//
//  ChatFirestoreMock.swift
//  ChatAppTests
//
//  Created by Дмитрий Данилин on 17.05.2022.
//

import Foundation
@testable import TinkoffChat

final class ChatFirestoreMock: ChatFirestoreProtocol {
    var invokedFetchChannels = false
    var invokedFetchChannelsCount = 0
    var stubbedFetchChannelsCompletionResult: (Result<[Channel], Error>, Void)?

    func fetchChannels(completion: @escaping (Result<[Channel], Error>) -> Void) {
        invokedFetchChannels = true
        invokedFetchChannelsCount += 1
        if let result = stubbedFetchChannelsCompletionResult {
            completion(result.0)
        }
    }

    var invokedAddNewChannel = false
    var invokedAddNewChannelCount = 0
    var invokedAddNewChannelParameters: (name: String, Void)?
    var invokedAddNewChannelParametersList = [(name: String, Void)]()

    func addNewChannel(name: String) {
        invokedAddNewChannel = true
        invokedAddNewChannelCount += 1
        invokedAddNewChannelParameters = (name, ())
        invokedAddNewChannelParametersList.append((name, ()))
    }

    var invokedDeleteChanel = false
    var invokedDeleteChanelCount = 0
    var invokedDeleteChanelParameters: (channelID: String, Void)?
    var invokedDeleteChanelParametersList = [(channelID: String, Void)]()

    func deleteChanel(channelID: String) {
        invokedDeleteChanel = true
        invokedDeleteChanelCount += 1
        invokedDeleteChanelParameters = (channelID, ())
        invokedDeleteChanelParametersList.append((channelID, ()))
    }

    var invokedFetchMessages = false
    var invokedFetchMessagesCount = 0
    var invokedFetchMessagesParameters: (channelID: String, Void)?
    var invokedFetchMessagesParametersList = [(channelID: String, Void)]()
    var stubbedFetchMessagesCompletionResult: (Result<[Message], Error>, Void)?

    func fetchMessages(
        channelID: String,
        completion: @escaping (Result<[Message], Error>) -> Void
    ) {
        invokedFetchMessages = true
        invokedFetchMessagesCount += 1
        invokedFetchMessagesParameters = (channelID, ())
        invokedFetchMessagesParametersList.append((channelID, ()))
        if let result = stubbedFetchMessagesCompletionResult {
            completion(result.0)
        }
    }

    var invokedSendMessage = false
    var invokedSendMessageCount = 0
    var invokedSendMessageParameters: (channelID: String, message: String, senderID: String)?
    var invokedSendMessageParametersList = [(channelID: String, message: String, senderID: String)]()

    func sendMessage(channelID: String, message: String, senderID: String) {
        invokedSendMessage = true
        invokedSendMessageCount += 1
        invokedSendMessageParameters = (channelID, message, senderID)
        invokedSendMessageParametersList.append((channelID, message, senderID))
    }
}
