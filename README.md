# ChatApp
![example workflow](https://github.com/TFS-iOS/chat-app-ZyFun/actions/workflows/github.yml/badge.svg)

## Description
Учебное приложение.

- Многопоточность приложения построена на GCD.
- Используются все принципы чистого кода, DRY,  KISS, YAGNI,  SOLID и SOA (не идеально, я только учусь 😅).
- Приложение написано на архитектуре MVC. 
- Используется UserDefaults для хранения настроек и FileManager для хранения изображений.
- В приложении присутствует работа с URLSession. С помощью него, через API подгружаются снимки, которые можно выбрать и установить в качестве аватарки профиля, или отправить в чате.
- Добавлено немного кастомной анимации. Переход на другой контроллер. Анимированная кнопка. Появление элементов на экране в точке касания,  до тех пор, пока касание продолжается.
- Код частично покрыт UI и Unit тестами, и настроен запуск тестов через Fastlane.
- Небольшая часть экранов написана кодом с помощью AutoLayout. 
- Весь дизайн приложения был взять из Figma

## Installations
- Приложение не запустится из-за отсутствия токенов сервера
- Если удасться его запустить подключив свой firebase с аналогичными настройками, картинки грузится не будут из-за санкций, если нет vpn.

## Screenshots

![Screenshot 1](https://github.com/ZyFun/ChatApp/blob/main/Screenshots/000.png?raw=true)
![Screenshot 2](https://github.com/ZyFun/ChatApp/blob/main/Screenshots/001.png?raw=true)
![Screenshot 6](https://github.com/ZyFun/ChatApp/blob/main/Screenshots/005.png?raw=true)
![Screenshot 3](https://github.com/ZyFun/ChatApp/blob/main/Screenshots/002.png?raw=true)
![Screenshot 4](https://github.com/ZyFun/ChatApp/blob/main/Screenshots/003.png?raw=true)
![Screenshot 5](https://github.com/ZyFun/ChatApp/blob/main/Screenshots/004.png?raw=true)
