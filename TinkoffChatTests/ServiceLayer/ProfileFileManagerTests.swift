//
//  ProfileFileManagerTests.swift
//  TinkoffChatTests
//
//  Created by Дмитрий Данилин on 13.05.2022.
//

import XCTest
@testable import TinkoffChat

class ProfileFileManagerTests: XCTestCase {
    // Опять пришлось создавать константы в switch result,
    // потому что swiftlint не даёт оставить их пустыми
    // но они мне здесь не нужны в данных тестах
    
    private var profileFileManagerMock: ProfileFileManagerMock!
    
    override func setUp() {
        super.setUp()
        profileFileManagerMock = ProfileFileManagerMock()
    }
    
    func testFetchProfileDataCalledAndProfileNotNil() {
        let profileManager = build()
        var profileData: Profile?
        // не  уверен что вообще правильно написал.
        // Я хочу проверить, возвращается ли вообще профиль и не пустой ли он
        // и возвращаю профиль без ошибок
        profileFileManagerMock.stubbedFetchProfileDataCompletionResult = (
            Result(
                catching: {
                    do {
                        return Profile(
                            name: "Test",
                            description: nil,
                            image: nil
                        )
                    }
                }
            ),
            ()
        )
        
        profileManager.loadProfile { result in
            switch result {
            case .success(let profile):
                profileData = profile
            case .failure(let error):
                _ = error
            }
        }
        
        XCTAssertTrue(profileFileManagerMock.invokedFetchProfileData)
        XCTAssertNotNil(profileData)
    }
    
    func testSaveProfileDataCalledEndSavedParameters() {
        let profileManager = build()
        let name = "Test"
        let description = "Test"
        let imageData: Data? = nil
        
        profileManager.saveProfile(
            name: name,
            description: description,
            imageData: imageData
        ) { result in
            switch result {
            case .success(let savedProfile):
                _ = savedProfile
            case .failure(let error):
                _ = error
            }
        }
        
        XCTAssertTrue(profileFileManagerMock.invokedSaveProfileData)
        XCTAssertEqual(
            profileFileManagerMock.invokedSaveProfileDataParameters?.name,
            name
        )
        XCTAssertEqual(
            profileFileManagerMock.invokedSaveProfileDataParameters?.description,
            description
        )
        XCTAssertEqual(
            profileFileManagerMock.invokedSaveProfileDataParameters?.imageData,
            imageData
        )
    }
    
    private func build() -> ProfileService {
        return ProfileService(
            profileFileManager: profileFileManagerMock
        )
    }
}
