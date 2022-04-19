//
//  MyProfileViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 18.02.2022.
//

import UIKit

final class MyProfileViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet weak var topBarView: UIView!
    
    @IBOutlet weak var noProfileImageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var editLogoButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    // Используется для того, чтобы поднять интерфейс на экранах с небольшим разрешением
    @IBOutlet weak var topConstraintProfileImage: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private properties
    
    private var profile: Profile?
    private var observer = NotificationKeyboardObserver()
    private let themeManager: ThemeManagerProtocol
    private let profileService: ProfileServiceProtocol
    private var imagePickerController: ImagePickerProfileManagerProtocol
    
    // MARK: - Initializer
    
    required init?(coder: NSCoder) {
        profileService = ProfileService()
        themeManager = ThemeManager.shared
        imagePickerController = ImagePickerProfileManager()
        super.init(coder: coder)
    }
    
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

    // MARK: - IB Actions
    
    @IBAction func editLogoButtonPressed() {
        changeProfileLogoAlertController()
        userNameTextField.text = nameLabel.text
        descriptionTextField.text = descriptionLabel.text
    }
    
    @IBAction func closeButtonPressed() {
        dismiss(animated: true)
    }
    
    @IBAction func editButtonPressed() {
        nameLabel.isHidden = true
        descriptionLabel.isHidden = true
        
        userNameTextField.isHidden = false
        descriptionTextField.isHidden = false
        
        showButtons(cancelButton, saveButton)
        hideButtons(editButton)
        
        userNameTextField.text = nameLabel.text
        descriptionTextField.text = descriptionLabel.text
        
        userNameTextField.becomeFirstResponder()
        
        // Состояние меняется, при изменении текста в TF
        setSaveButtonIsNotActive()
    }
    
    @IBAction func cancelButtonPressed() {
        view.endEditing(true)
        
        // Возврат к текущему состоянию с отменой изменений
        if let imageData = profile?.image {
            profileImageView.image = UIImage(data: imageData)
        } else {
            profileImageView.image = nil
            noProfileImageLabel.text = setFirstCharacters(from: profile?.name)
            noProfileImageLabel.isHidden = false
        }
        
        userNameTextField.isHidden = true
        descriptionTextField.isHidden = true
        
        nameLabel.isHidden = false
        descriptionLabel.isHidden = false
        
        showButtons(
            editButton,
            editLogoButton // Нужно в тот момент, когда скрывается кнопка при изменении изображения
        )
        
        hideButtons(
            cancelButton,
            saveButton
        )
    }
    
    @IBAction func saveButtonPressed() {
        activityIndicator.startAnimating()
        
        let userName = userNameTextField.text
        let description = descriptionTextField.text
        
        if profileImageView.image == nil {
            noProfileImageLabel.text = setFirstCharacters(from: userName)
        }
        
        setSaveButtonIsNotActive()
        setEditButtonIsNotActive()
        setTextFieldsIsNotActive()
        
        profileService.saveProfileData(
            name: userName,
            description: description,
            imageData: profileImageView.image?.pngData()
        ) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let swiftlint):
                    // TODO: ([11.04.2022]) swiftlint не даёт оставить пустым, хотя мне не нужно отсюда ничего.
                    Logger.info("\(swiftlint)", showInConsole: false)
                    
                    // Нужно для того, чтобы при нажатии на cancel
                    // не происходило изменений, так как данные уже сохранены
                    self.profile?.image = self.profileImageView.image?.pngData()
                    // TODO: ([20.03.2022]) Имя скорее всего должно быть обязательным, по этому пока так
                    if userName != "" {
                        self.nameLabel.text = userName
                    }
                    self.descriptionLabel.text = description
                    
                    self.showResultAlert(isResultError: false)
                case .failure(let error):
                    Logger.warning(error.localizedDescription)
                    self.showResultAlert(isResultError: true)
                }
                
                self.activityIndicator.stopAnimating()
            }
        }
    }
}

// MARK: - Private properties

private extension MyProfileViewController {
    func setup() {
        loadProfile()
        
        setupActivityIndicator()
        setupViews()
        setupButtons()
        setupTextFields()
        setupProfileImage()
        setupLabels()
    }
    
    func loadProfile() {
        activityIndicator.startAnimating()
        
        profileService.fetchProfileData { [weak self] result in
            switch result {
            case .success(let savedProfile):
                self?.profile = savedProfile
                
                DispatchQueue.main.async {
                    self?.setupProfileImage()
                    self?.setupLabels()
                    self?.activityIndicator.stopAnimating()
                }
            case .failure(let error):
                printDebug("Что то пошло не так: \(error)")
                // TODO: ([21.03.2022]) Нужен будет алерт о том, что данные не получены
            }
        }
    }
    
    func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemGray
        activityIndicator.style = .large
    }
    
    func setupViews() {
        topBarView.backgroundColor = themeManager.appColorLoadFor(.backgroundNavBar)
        view.backgroundColor = themeManager.appColorLoadFor(.backgroundView)
    }
    
    // MARK: - Profile image settings
    
    func setupProfileImage() {
        if let imageData = profile?.image {
            profileImageView.image = UIImage(data: imageData)
            noProfileImageLabel.isHidden = true
        } else {
            setupNoProfileImageLabel()
        }
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.backgroundColor = themeManager.appColorLoadFor(.profileImageView)
    }
    
    func setupProfileImageSize() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
    
    func setupNoProfileImageLabel() {
        noProfileImageLabel.text = setFirstCharacters(from: profile?.name)
        noProfileImageLabel.textColor = themeManager.appColorLoadFor(.textImageView)
        noProfileImageLabel.adjustsFontSizeToFitWidth = true
        noProfileImageLabel.baselineAdjustment = .alignCenters
        noProfileImageLabel.minimumScaleFactor = 0.5
        noProfileImageLabel.isHidden = false
    }
    
    // TODO: ([30.03.2022]) Логика частично дублируется на нескольких экранах, отрефакторить. (Ячейка канала)
    // сделать в отдельном менеджере по управлению изображениями, так-как на данный момент они присутствуют в трех местах
    func setFirstCharacters(from fullName: String?) -> String? {
        if let fullName = fullName {
            let separateFullName = fullName.split(separator: " ")
            let numberWords = separateFullName.count
            var characters = ""
            
            if numberWords == 1 {
                guard let firstSymbol = separateFullName.first?.first else { return "UN" }
                return String(firstSymbol)
            } else {
                guard let firstSymbol = separateFullName.first?.first else { return "UN" }
                guard let lastSymbol = separateFullName.last?.first else { return "UN" }
                characters = "\(firstSymbol)\(lastSymbol)"
            }
            
            let bigCharacters = characters.uppercased()
            
            return bigCharacters
        } else {
            return "UN"
        }
    }
    
    // MARK: - Labels settings
    
    func setupLabels() {
        titleLabel.textColor = themeManager.appColorLoadFor(.text)
        nameLabel.textColor = themeManager.appColorLoadFor(.text)
        descriptionLabel.textColor = themeManager.appColorLoadFor(.text)
        
        nameLabel.text = profile?.name
        descriptionLabel.text = profile?.description
    }
    
    // MARK: - Textfield settings
    
    func setupTextFields() {
        userNameTextField.delegate = self
        descriptionTextField.delegate = self
        
        userNameTextField.textColor = themeManager.appColorLoadFor(.text)
        descriptionTextField.textColor = themeManager.appColorLoadFor(.text)
        
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
    
    // TODO: ([19.03.2022]) Если поле с именем должно будет быть обязательным, добавить сюда логику на проверку nil и не отображать кнопки сохранения
    @objc func profileTextFieldDidChanged() {
        if userNameTextField.text != nameLabel.text
        || descriptionTextField.text != descriptionLabel.text {
            setSaveButtonIsActive()
        } else {
            setSaveButtonIsNotActive()
        }
    }
    
    // - MARK: Button settings
    
    func setupButtons() {
        editLogoButton.titleLabel?.font = .systemFont(ofSize: 16)
        
        settingButtons(
            editButton,
            cancelButton,
            saveButton
        )
        
        hideButtons(
            cancelButton,
            saveButton
        )
    }
    
    func settingButtons(_ buttons: UIButton...) {
        for button in buttons {
            button.backgroundColor = themeManager.appColorLoadFor(.button)
            button.layer.cornerRadius = 14
            button.titleLabel?.font = .systemFont(ofSize: 19)
            button.setTitleColor(.systemBlue, for: .normal)
        }
    }
    
    func setSaveButtonIsActive() {
        saveButton.isEnabled = true
        saveButton.setTitleColor(.systemBlue, for: .normal)
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
    
    func setSaveButtonIsNotActive() {
        saveButton.isEnabled = false
        saveButton.setTitleColor(.systemGray, for: .normal)
    }
    
    // - MARK: Alert Controllers
    
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
            self.setSaveButtonIsActive()
            self.setTextFieldsIsActive()
            
            if !isResultError {
                self.userNameTextField.isHidden = true
                self.descriptionTextField.isHidden = true
                
                self.nameLabel.isHidden = false
                self.descriptionLabel.isHidden = false
                
                self.hideButtons(
                    self.cancelButton,
                    self.saveButton
                )
                
                self.showButtons(self.editButton)
            }
        }
        
        let repeatButton = UIAlertAction(
            title: "Повторить",
            style: .default
        ) { [weak self] _ in
            self?.saveButtonPressed()
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
            self?.imagePickerController.chooseImagePicker(source: .camera)
            self?.imagePickerController.didSelectPickerController = { imagePicker in
                self?.present(imagePicker, animated: true)
            }
            self?.setChosenImage()
        }
        
        let photo = UIAlertAction(title: "Установить из галлереи", style: .default) { [weak self] _ in
            self?.imagePickerController.chooseImagePicker(source: .photoLibrary)
            self?.imagePickerController.didSelectPickerController = { imagePicker in
                self?.present(imagePicker, animated: true)
            }
            self?.setChosenImage()
        }
        
        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
        
        choosePhoto.addAction(camera)
        choosePhoto.addAction(photo)
        choosePhoto.addAction(cancel)
        
        let currentTheme = themeManager.currentTheme
        if currentTheme == Theme.night.rawValue {
            choosePhoto.overrideUserInterfaceStyle = .dark
        } else {
            choosePhoto.overrideUserInterfaceStyle = .light
        }
        
        present(choosePhoto, animated: true)
    }
    
    func setChosenImage() {
        imagePickerController.didSelectImage = { [weak self] image in
            guard let strongSelf = self else { return }
            strongSelf.profileImageView.image = image
            strongSelf.imagePickerController.closeImagePicker {
                if strongSelf.profileImageView != nil {
                    strongSelf.noProfileImageLabel.isHidden = true
                }
                
                strongSelf.showButtons(
                    strongSelf.cancelButton,
                    strongSelf.saveButton
                )
                strongSelf.setSaveButtonIsActive()
                strongSelf.hideButtons(
                    strongSelf.editLogoButton,
                    strongSelf.editButton
                )
            }
        }
    }
}

// MARK: - Text Field Delegate

extension MyProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // TODO: ([29.03.2022]) Кривой костыль. Перекрывает поля ввода на некоторых экранах. нужно подумать как это улучшить.
        topConstraintProfileImage.constant = -130
        
        if profileImageView.image == nil {
            noProfileImageLabel.isHidden = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // TODO: ([29.03.2022]) Кривой костыль. Перекрывает поля ввода на некоторых экранах. нужно подумать как это улучшить.
        topConstraintProfileImage.constant = 7
        
        if profileImageView.image == nil {
            noProfileImageLabel.isHidden = false
        }
    }
}
