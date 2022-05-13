//
//  ProfileManagerTests.swift
//  TinkoffChatTests
//
//  Created by Дмитрий Данилин on 13.05.2022.
//

import XCTest
@testable import TinkoffChat

class ProfileManagerTests: XCTestCase {
    // Опять пришлось создавать константы в switch result,
    // потому что swiftlint не даёт оставить их пустыми
    // но они мне здесь не нужны в данных тестах
    
    private let profileManagerMock = ProfileServiceMock()
    
    func testFetchProfileDataCalled() {
        let profileManager = build()
        
        profileManager.loadProfile { result in
            switch result {
            case .success(let profile):
                _ = profile
            case .failure(let error):
                _ = error
            }
        }
        
        XCTAssertTrue(profileManagerMock.invokedFetchProfileData)
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
        
        XCTAssertTrue(profileManagerMock.invokedSaveProfileData)
        XCTAssertEqual(
            profileManagerMock.invokedSaveProfileDataParameters?.name,
            name
        )
        XCTAssertEqual(
            profileManagerMock.invokedSaveProfileDataParameters?.description,
            description
        )
        XCTAssertEqual(
            profileManagerMock.invokedSaveProfileDataParameters?.imageData,
            imageData
        )
    }
    
    private func build() -> ProfileManager {
        return ProfileManager(
            profileService: profileManagerMock
        )
    }
}
