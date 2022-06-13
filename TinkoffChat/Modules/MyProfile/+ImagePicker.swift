//
//  +ImagePicker.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 26.03.2022.
//

import UIKit
import Photos

// TODO: ([26.03.2022]) Временное решение, нужно сделать не экстеншеном, а отдельным классом для работы с выбором фото профиля
extension MyProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        profileImageView.image = info[.editedImage] as? UIImage
        
        if profileImageView != nil {
            noProfileImageLabel.isHidden = true
        }
        
        dismiss(animated: true) { [weak self] in
            // TODO: ([18.03.2022]) Отрабатывает с паузой. Надо подумать как можно улучшить
            guard let self = self else { return }
            
            self.showButtons(
                self.cancelButton,
                self.saveButton
            )
            
            self.setSaveButtonIsActive()
            
            self.hideButtons(
                self.editLogoButton,
                self.editButton
            )
        }
    }
    
    // MARK: - Private methods
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            
            if imagePicker.sourceType == .photoLibrary {
                checkPermission(library: imagePicker)
            } else {
                checkPermission(camera: imagePicker)
            }
        }
    }
    
    private func checkPermission(camera imagePicker: UIImagePickerController) {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] response in
            if response {
                DispatchQueue.main.async {
                    self?.present(imagePicker, animated: true)
                    printDebug("Access granted")
                }
            } else {
                // TODO: ([02.03.2022]) Сделать алерт c перенаправлением в настройки приватности
                printDebug("User denied access")
            }
        }
    }
    
    private func checkPermission(library imagePicker: UIImagePickerController) {
       let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
       switch photoAuthorizationStatus {
       case .authorized:
           present(imagePicker, animated: true)
           printDebug("Access granted")
       case .notDetermined:
           PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
               if newStatus == .authorized {
                   DispatchQueue.main.async {
                       self?.present(imagePicker, animated: true)
                   }
                   printDebug("success")
               }
           }
           
           printDebug("User has not yet made a selection")
       case .restricted:
           // TODO: ([02.03.2022]) Можно вывести алерт о запрете доступа к галерее
           printDebug("User cannot access the library")
       case .denied:
           // TODO: ([02.03.2022]) Сделать алерт c перенаправлением в настройки приватности
           printDebug("User denied access")
       case .limited:
           // Как я понял из документации, метод authorizationStatus не
           // совместим с этим кейсом. Но совместимые методы не совместимы с
           // таргетом версии iOS, так как они работают только с 14 iOS. Нужно
           // почитать подробнее для себя, как работать со всем этим при
           // использовании нового метода. Либо есть что-то специальное, либо
           // нужно писать отдельный экран, где будут отображаться снимки,
           // которые были одобрены пользователем, с возможностью добавлять новые.
           // Нужно разобраться, возможно ли показывать алерт выбора доступа
           // без selected photos... Или для более новых версий обязательно писать такую логику.
           printDebug("User has allowed access to some photos")
       @unknown default:
           printDebug("Oops \(#function)")
           return
       }
   }
}
