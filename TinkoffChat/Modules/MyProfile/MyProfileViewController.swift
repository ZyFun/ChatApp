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
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveGCDButton: UIButton!
    @IBOutlet weak var saveOperationButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
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
    
    // TODO: Переименовать в save или оставить так же, после ответа в слаке.
    @IBAction func editButtonPressed() {
        nameLabel.isHidden = true
        descriptionLabel.isHidden = true
        
        userNameTextField.isHidden = false
        descriptionTextField.isHidden = false
        
        showButtons(
            cancelButton,
            saveGCDButton,
            saveOperationButton
        )
        
        hideButtons(saveButton)
        
        userNameTextField.text = nameLabel.text
        descriptionTextField.text = descriptionLabel.text
        
        userNameTextField.becomeFirstResponder()
        
        // Состояние меняется, при изменении текста в TF
        setSaveButtonsIsNotActive()
    }
    
    @IBAction func cancelButtonPressed() {
        userNameTextField.isHidden = true
        descriptionTextField.isHidden = true
        
        nameLabel.isHidden = false
        descriptionLabel.isHidden = false
        
        showButtons(saveButton)
        
        hideButtons(
            cancelButton,
            saveGCDButton,
            saveOperationButton
        )
    }
    
    @IBAction func saveGCDButtonPressed() {
        // Имя скорее всего должно быть обязательным, по этому так
        if userNameTextField.text != "" {
            nameLabel.text = userNameTextField.text
        }
        descriptionLabel.text = descriptionTextField.text
        
        userNameTextField.isHidden = true
        descriptionTextField.isHidden = true
        
        nameLabel.isHidden = false
        descriptionLabel.isHidden = false
        
        hideButtons(
            cancelButton,
            saveGCDButton,
            saveOperationButton
        )
        
        showButtons(saveButton)
    }
    @IBAction func saveOperationButtonPressed() {
        // Имя скорее всего должно быть обязательным, по этому так
        if userNameTextField.text != "" {
            nameLabel.text = userNameTextField.text
        }
        descriptionLabel.text = descriptionTextField.text
        
        userNameTextField.isHidden = true
        descriptionTextField.isHidden = true
        
        nameLabel.isHidden = false
        descriptionLabel.isHidden = false
        
        hideButtons(
            cancelButton,
            saveGCDButton,
            saveOperationButton
        )
        
        showButtons(saveButton)
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
        setupTextFields()
        setupThemeVC()
    }
    
    func setupTopBarView() {
        topBarView.backgroundColor = .appColorLoadFor(.backgroundNavBar)
    }
    
    func setupProfileImage() {
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.backgroundColor = .appColorLoadFor(.profileImageView)
        setupNoProfileImageLabel()
    }
    
    func setupNoProfileImageLabel() {
        noProfileImageLabel.textColor = .appColorLoadFor(.textImageView)
        noProfileImageLabel.adjustsFontSizeToFitWidth = true
        noProfileImageLabel.baselineAdjustment = .alignCenters
        noProfileImageLabel.minimumScaleFactor = 0.5
    }
    
    func setupProfileImageSize() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
    
    func setupThemeVC() {
        view.backgroundColor = .appColorLoadFor(.backgroundView)
        
        titleLabel.textColor = .appColorLoadFor(.text)
        nameLabel.textColor = .appColorLoadFor(.text)
        descriptionLabel.textColor = .appColorLoadFor(.text)
    }
    
    func setupTextFields() {
        userNameTextField.textColor = .appColorLoadFor(.text)
        descriptionTextField.textColor = .appColorLoadFor(.text)
        
        userNameTextField.isHidden = true
        descriptionTextField.isHidden = true
        
        userNameTextField.delegate = self
        descriptionTextField.delegate = self
    }
    
    // MARK: Button settings
    func setupButtons() {
        editLogoButton.titleLabel?.font = .systemFont(ofSize: 16)
        
        settingButtons(
            saveButton,
            cancelButton,
            saveGCDButton,
            saveOperationButton
        )
        
        hideButtons(
            cancelButton,
            saveGCDButton,
            saveOperationButton
        )
    }
    
    func settingButtons(_ buttons: UIButton...) {
        for button in buttons {
            button.backgroundColor = .appColorLoadFor(.button)
            button.layer.cornerRadius = 14
            button.titleLabel?.font = .systemFont(ofSize: 19)
            button.setTitleColor(.systemBlue, for: .normal)
        }
    }
    
    func hideButtons(_ buttons: UIButton...) {
        for button in buttons {
            button.isHidden = true
        }
    }
    
    func showButtons(_ buttons: UIButton...) {
        for button in buttons {
            button.isHidden = false
        }
    }
    
    func setSaveButtonsIsNotActive() {
        saveGCDButton.isEnabled = false
        saveGCDButton.setTitleColor(.systemGray, for: .normal)
        
        saveOperationButton.isEnabled = false
        saveOperationButton.setTitleColor(.systemGray, for: .normal)
    }
    
    func setSaveButtonsIsActive() {
        saveGCDButton.isEnabled = true
        saveGCDButton.setTitleColor(.systemBlue, for: .normal)
        
        saveOperationButton.isEnabled = true
        saveOperationButton.setTitleColor(.systemBlue, for: .normal)
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
        
        let currentTheme = ThemeManager.shared.currentTheme
        if currentTheme == Theme.night.rawValue {
            choosePhoto.overrideUserInterfaceStyle = .dark
        } else {
            choosePhoto.overrideUserInterfaceStyle = .light
        }
        
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

// MARK: - Text Field Delegate
extension MyProfileViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        
        guard let currentText = textField.text else { return true }
        guard let stringRange = Range(range, in: currentText) else { return true }

        let updatedText = currentText.replacingCharacters(
            in: stringRange,
            with: string
        )
        
        if updatedText.count != nameLabel.text?.count
        && updatedText.count != descriptionLabel.text?.count {
            setSaveButtonsIsActive()
        }
        
        return true
    }
}
