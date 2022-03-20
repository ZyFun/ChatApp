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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Private properties
    private var profile: Profile?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupProfileImageSize()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
        // Возврат к текущему состоянию с отменой изменений
        if let imageData = profile?.image {
            profileImageView.image = UIImage(data: imageData)
        } else {
            noProfileImageLabel.text = setFirstCharacters(from: profile?.name)
            noProfileImageLabel.isHidden = false
        }
        
        userNameTextField.isHidden = true
        descriptionTextField.isHidden = true
        
        nameLabel.isHidden = false
        descriptionLabel.isHidden = false
        
        showButtons(
            saveButton,
            editLogoButton // Нужно в тот момент, когда скрывается кнопка при изменении изображения
        )
        
        hideButtons(
            cancelButton,
            saveGCDButton,
            saveOperationButton
        )
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let userName = userNameTextField.text
        let description = descriptionTextField.text
        
        if profileImageView.image == nil {
            noProfileImageLabel.text = setFirstCharacters(from: userName)
        }
        
        if sender == saveGCDButton {
            activityIndicator.startAnimating()
            
            setSaveButtonsIsNotActive()
            setEditButtonIsNotActive()
            setTextFieldsIsNotActive()
            
            DataManagerWithGCD.shared.saveProfileData(
                name: userName,
                description: description,
                imageData: profileImageView.image?.pngData()
            ) { [weak self] response in
                guard let self = self else { return }
                
                if response == nil {
                    // Нужно для того, чтобы при нажатии на cancel
                    // не происходило изменений, так как данные уже сохранены
                    self.profile?.image = self.profileImageView.image?.pngData()
                    // TODO: Имя скорее всего должно быть обязательным, по этому пока так
                    if userName != "" {
                        self.nameLabel.text = userName
                    }
                    self.descriptionLabel.text = description
                    
                    self.showResultAlert(isResultError: false)
                } else {
                    self.showResultAlert(
                        isResultError: true,
                        senderButton: sender
                    )
                }
                
                self.activityIndicator.stopAnimating()
            }
        } else {
            // Логика для сохранения с помощью Operation
            StorageManager.shared.saveProfileData(
                name: userName,
                describing: description,
                imageData: profileImageView.image?.pngData()
            )
        }
    }
}

// MARK: - Private properties
private extension MyProfileViewController {
    func setup() {
        profile = StorageManager.shared.fetchProfileData()
        
        activityIndicator.hidesWhenStopped = true
        
        setupViews()
        setupProfileImage()
        setupLabels()
        setupButtons()
        setupTextFields()
    }
    
    func setupViews() {
        topBarView.backgroundColor = .appColorLoadFor(.backgroundNavBar)
        view.backgroundColor = .appColorLoadFor(.backgroundView)
    }
    
    // MARK: Profile image settings
    func setupProfileImage() {
        if let imageData = profile?.image {
            profileImageView.image = UIImage(data: imageData)
            noProfileImageLabel.isHidden = true
        } else {
            setupNoProfileImageLabel()
        }
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.backgroundColor = .appColorLoadFor(.profileImageView)
    }
    
    func setupProfileImageSize() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
    
    func setupNoProfileImageLabel() {
        noProfileImageLabel.text = setFirstCharacters(from: profile?.name)
        noProfileImageLabel.textColor = .appColorLoadFor(.textImageView)
        noProfileImageLabel.adjustsFontSizeToFitWidth = true
        noProfileImageLabel.baselineAdjustment = .alignCenters
        noProfileImageLabel.minimumScaleFactor = 0.5
        noProfileImageLabel.isHidden = false
    }
    
    func setFirstCharacters(from fullName: String?) -> String? {
        if let fullName = fullName {
            let separateFullName = fullName.split(separator: " ")
            let firstSymbol = separateFullName.first?.first
            let lastSymbol = separateFullName.last?.first
            let characters = "\(firstSymbol!)\(lastSymbol!)"
            
            return characters
        } else {
            return "UN"
        }
    }
    
    // MARK: Labels settings
    func setupLabels() {
        titleLabel.textColor = .appColorLoadFor(.text)
        nameLabel.textColor = .appColorLoadFor(.text)
        descriptionLabel.textColor = .appColorLoadFor(.text)
        
        nameLabel.text = profile?.name
        descriptionLabel.text = profile?.description
    }
    
    // MARK: Textfield settings
    func setupTextFields() {
        userNameTextField.delegate = self
        descriptionTextField.delegate = self
        
        userNameTextField.textColor = .appColorLoadFor(.text)
        descriptionTextField.textColor = .appColorLoadFor(.text)
        
        userNameTextField.isHidden = true
        descriptionTextField.isHidden = true
        
        userNameTextField.addTarget(
            self,
            action: #selector(profileTextFieldDidChanged),
            for: .editingChanged)
        
        descriptionTextField.addTarget(
            self,
            action: #selector(profileTextFieldDidChanged),
            for: .editingChanged)
    }
    
    func setTextFieldsIsNotActive() {
        userNameTextField.isEnabled = false
        descriptionTextField.isEnabled = false
    }
    
    func setTextFieldsIsActive() {
        userNameTextField.isEnabled = true
        descriptionTextField.isEnabled = true
    }
    
    // TODO: Если поле с именем должно будет быть обязательным, добавить сюда логику на проверку nil и не отображать кнопки сохранения
    @objc func profileTextFieldDidChanged() {
        if userNameTextField.text != nameLabel.text
        || descriptionTextField.text != descriptionLabel.text {
            setSaveButtonsIsActive()
        } else {
            setSaveButtonsIsNotActive()
        }
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
    
    func setEditButtonIsNotActive() {
        editLogoButton.isEnabled = false
        editLogoButton.tintColor = .systemGray
    }
    
    func setEditButtonIsActive() {
        editLogoButton.isEnabled = true
        editLogoButton.tintColor = .systemBlue
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
    
    // MARK: Alert Controllers
    // Принимает значение по умолчанию в виде кнопки, для того
    // чтобы не передавать кнопку если результат работы клоужера был без ошибки
    func showResultAlert(isResultError: Bool, senderButton: UIButton = UIButton()) {
        var title: String?
        var message: String?
        
        if isResultError {
            title = "Ошибка"
            message = "Не удалось сохранить данные"
        } else {
            title = "Данные сохранены"
        }
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okButton = UIAlertAction(title: "Ок", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            
            self.setEditButtonIsActive()
            self.setSaveButtonsIsActive()
            self.setTextFieldsIsActive()
            
            if !isResultError {
                self.userNameTextField.isHidden = true
                self.descriptionTextField.isHidden = true
                
                self.nameLabel.isHidden = false
                self.descriptionLabel.isHidden = false
                
                self.hideButtons(
                    self.cancelButton,
                    self.saveGCDButton,
                    self.saveOperationButton
                )
                
                self.showButtons(self.saveButton)
            }
        }
        
        let repeatButton = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            if senderButton == self?.saveGCDButton {
                self?.saveButtonPressed(senderButton)
            } else {
                self?.saveButtonPressed(senderButton)
            }
        }
        
        alert.addAction(okButton)
        
        if isResultError {
            alert.addAction(repeatButton)
        }
        
        present(alert, animated: true)
        
    }
    
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
        
        // TODO: Отрабатывает с паузой. Надо подумать как можно улучшить
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            self.showButtons(
                self.cancelButton,
                self.saveGCDButton,
                self.saveOperationButton
            )
            
            self.setSaveButtonsIsActive()
            
            self.hideButtons(
                self.editLogoButton,
                self.saveButton
            )
            
            // TODO: Костыль для защиты от обнуления TF, возможно есть варианты получше. Как вариант, делать проверку на nil при нажатие на сохранение.
            self.userNameTextField.text = self.nameLabel.text
            self.descriptionTextField.text = self.descriptionLabel.text
        }
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
