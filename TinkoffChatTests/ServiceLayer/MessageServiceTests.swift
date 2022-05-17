//
//  MessageServiceTests.swift
//  TinkoffChatTests
//
//  Created by Дмитрий Данилин on 17.05.2022.
//

import XCTest
@testable import TinkoffChat

class MessageServiceTests: XCTestCase {
    
    private var chatFirestoreMock: ChatFirestoreMock!
    
    override func setUp() {
        super.setUp()
        
        chatFirestoreMock = ChatFirestoreMock()
    }
    
    func testSendMessageCalledAndSendingMessage() {
        let messageService = build()
        let channelID = "Test channel ID"
        let senderID = "Test sender ID"
        let message = "Test message"
        var isMessageSent = false
        
        messageService.sendMessage(
            channelID: channelID,
            senderID: senderID,
            message: message
        ) {
            isMessageSent.toggle()
        }
        
        XCTAssertTrue(chatFirestoreMock.invokedSendMessage)
        XCTAssertTrue(isMessageSent)
        XCTAssertEqual(
            chatFirestoreMock.invokedSendMessageParameters?.channelID,
            channelID
        )
        XCTAssertEqual(
            chatFirestoreMock.invokedSendMessageParameters?.senderID,
            senderID
        )
        XCTAssertEqual(
            chatFirestoreMock.invokedSendMessageParameters?.message,
            message
        )
    }
    
    private func build() -> MessageService {
        return MessageService(
            chatFirestore: chatFirestoreMock
        )
    }
}
