//
//  ProfileScreenTests.swift
//  TinkoffChatUITests
//
//  Created by Дмитрий Данилин on 14.05.2022.
//

import XCTest

class ProfileScreenTests: XCTestCase {
    
    func testProfile() {
        let app = XCUIApplication()
        
        // TODO: ([14.05.2022]) Не знаю, правильный подход или нет
        // нашел такое решение нагуглив проблему. У меня было время ожидания
        // завершения какой то анимации, примерно в минуту. Видимо кнопки.
        // По этому я полностью отключил анимацию при прогоне тестов.
        app.launchArguments.append("--UITests")
        app.launch()
        app.navigationBars["Channels"].buttons["UN"].tap()
        app.staticTexts["My Profile"].tap()
        app.images["profileImageView"].tap()
        
        app.buttons["editPhotoButton"].staticTexts["Edit"].tap()
        app.sheets.scrollViews.otherElements.buttons["Отмена"].tap()
        
        app.buttons["editButton"].tap()
        app.textFields["userNameTF"].tap()
        app.textFields["descriptionTF"].tap()
        app.buttons["Done"].tap() // не забудь включить клавиатуру перед тестом
        app.buttons["cancelButton"].tap()
        
        app.buttons["Close"].tap()
    }
}
