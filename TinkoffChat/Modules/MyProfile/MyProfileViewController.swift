//
//  ViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 18.02.2022.
//

import UIKit
import Photos

final class MyProfileViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var noProfileImageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editLogoButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupProfileImageSize()
    }

    // MARK: IB Actions
    @IBAction func editLogoButtonPressed() {
        changeProfileLogoAlertController()
    }
    
    @IBAction func closeButtonPressed() {
        dismiss(animated: true)
    }
}

// MARK: - Private properties
private extension MyProfileViewController {
    func setup() {
        setupUI()
    }
    
    func setupUI() {
        setupTopBarView()
        setupProfileImage()
        setupButtons()
    }
    
    func setupTopBarView() {
        topBarView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    }
    
    func setupProfileImage() {
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.backgroundColor = #colorLiteral(red: 0.8941176471, green: 0.9098039216, blue: 0.168627451, alpha: 1)
        setupNoProfileImageLabel()
    }
    
    func setupNoProfileImageLabel() {
        noProfileImageLabel.adjustsFontSizeToFitWidth = true
        noProfileImageLabel.baselineAdjustment = .alignCenters
        noProfileImageLabel.minimumScaleFactor = 0.5
    }
    
    func setupProfileImageSize() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
    
    func setupButtons() {
        saveButton.backgroundColor = #colorLiteral(red: 0.9647058845, green: 0.9647058845, blue: 0.9647058845, alpha: 1)
        saveButton.layer.cornerRadius = 14
        saveButton.titleLabel?.font = .systemFont(ofSize: 19)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        
        editLogoButton.titleLabel?.font = .systemFont(ofSize: 16)
    }
    
    // MARK: Alert Controller
    func changeProfileLogoAlertController() {
        let choosePhoto = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Сделать фото", style: .default) { [weak self] _ in
            self?.chooseImagePicker(source: .camera)
        }
        
        let photo = UIAlertAction(title: "Установить из галлереи", style: .default) { [weak self] _ in
            self?.chooseImagePicker(source: .photoLibrary)
        }
        
        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
        
        choosePhoto.addAction(camera)
        choosePhoto.addAction(photo)
        choosePhoto.addAction(cancel)
        
        present(choosePhoto, animated: true)
    }
}

// MARK: - Работа с изображениями
extension MyProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        profileImageView.image = info[.editedImage] as? UIImage
        
        if profileImageView != nil {
            noProfileImageLabel.isHidden = true
        }

        dismiss(animated: true)
    }
    
    // MARK: Private methods
    private func chooseImagePicker(source: UIImagePickerController.SourceType) {
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
                // TODO: Сделать алерт c перенаправлением в настройки приватности
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
           // TODO: Можно вывести алерт о запрете доступа к галерее
           printDebug("User cannot access the library")
       case .denied:
           // TODO: Сделать алерт c перенаправлением в настройки приватности
           printDebug("User denied access")
       case .limited:
           // Как я понял из документации, метод authorizationStatus не совместим с этим кейсом. Но совместимые методы не совместимы с таргетом версии iOS, так как они работают только с 14 iOS. Нужно почитать подробнее для себя, как работать со всем этим при использовании нового метода. Либо есть что-то специальное, либо нужно писать отдельный экран, где будут отображаться снимки, которые были одобрены пользователем, с возможностью добавлять новые.
           // Нужно разобраться, возможно ли показывать алерт выбора доступа без selected photos... Или для более новых версий обязательно писать такую логику.
           printDebug("User has allowed access to some photos")
       @unknown default:
           printDebug("Oops \(#function)")
           return
       }
   }
}
