![Xcode](https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white)
![Swift](https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white)
![IOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)
<br/>
![UIKit](https://img.shields.io/badge/-UIKit-blue)
![AutoLayout](https://img.shields.io/badge/-AutoLayout-blue)
![XIB](https://img.shields.io/badge/-XIB-blue)
![MVC](https://img.shields.io/badge/-MVC-blue)
![UserDefaults](https://img.shields.io/badge/-UserDefaults-blue)
![FileManager](https://img.shields.io/badge/-FileManager-blue)
![CoreData](https://img.shields.io/badge/-CoreData-blue)
![Firebase](https://img.shields.io/badge/-Firebase-blue)
![JSON](https://img.shields.io/badge/-JSON-blue)
![URLSession](https://img.shields.io/badge/-URLSession-blue)
![URLRequest](https://img.shields.io/badge/-URLRequest-blue)
![GCD](https://img.shields.io/badge/-GCD-blue)
![Fastlane](https://img.shields.io/badge/-Fastlane-blue)
![UnitTests](https://img.shields.io/badge/-UnitTests-blue)
![UITests](https://img.shields.io/badge/-UITests-blue)

# ChatApp
![example workflow](https://github.com/TFS-iOS/chat-app-ZyFun/actions/workflows/github.yml/badge.svg)

## Description
Учебное приложение.

- Многопоточность приложения построена на GCD.
- Используются все принципы чистого кода, DRY,  KISS, YAGNI,  SOLID и SOA (не идеально, я только учусь 😅).
- Приложение написано на архитектуре MVC. 
- Используется UserDefaults для хранения настроек и FileManager для хранения изображений.
- В качестве кеша и для работы с таблицами, используется CoreData (В учебных целях).
- В приложении присутствует работа с URLSession. С помощью него, через API подгружаются снимки, которые можно выбрать и установить в качестве аватарки профиля, или отправить в чате.
- Добавлено немного кастомной анимации. Переход на другой контроллер. Анимированная кнопка. Появление элементов на экране в точке касания,  до тех пор, пока касание продолжается.
- Код частично покрыт UI и Unit тестами, и настроен запуск тестов через Fastlane.
- Небольшая часть экранов написана кодом с помощью AutoLayout. 
- Весь дизайн приложения был взять из Figma

## Installations
- Приложение не запустится из-за отсутствия токенов сервера
- Если удасться его запустить подключив свой firebase с аналогичными настройками, картинки грузится не будут из-за санкций, если нет vpn.

## Screenshots
<img src="https://github.com/ZyFun/ChatApp/blob/main/Screenshots/Screenshot000.png" width="252" height="488" /> <img src="https://github.com/ZyFun/ChatApp/blob/main/Screenshots/Screenshot001.png" width="252" height="488" /> <img src="https://github.com/ZyFun/ChatApp/blob/main/Screenshots/Screenshot002.png" width="252" height="488" /> <img src="https://github.com/ZyFun/ChatApp/blob/main/Screenshots/Screenshot003.png" width="252" height="488" /> <img src="https://github.com/ZyFun/ChatApp/blob/main/Screenshots/Screenshot004.png" width="252" height="488" /> <img src="https://github.com/ZyFun/ChatApp/blob/main/Screenshots/Screenshot005.png" width="252" height="488" /> <img src="https://github.com/ZyFun/ChatApp/blob/main/Screenshots/Screenshot006.png" width="252" height="488" /> 
