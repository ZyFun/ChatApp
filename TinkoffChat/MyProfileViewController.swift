//
//  ViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 18.02.2022.
//

import UIKit
import Photos

final class MyProfileViewController: UIViewController {
    
    // MARK: IB Outlets
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var noProfileImageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editLogoButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - LifeCycle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        printDebug("View instance created: \(#function)")
        
        // saveButton.frame не будет распечатан в этом методе, потому что кнопка еще не инициализирована и её еще нет в памяти.
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        printDebug(saveButton.frame)
        
        printDebug("View has been loaded into memory: \(#function)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        printDebug("View will be added to the hierarchy from memory: \(#function)")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupProfileImageSize()
        
        printDebug("View is getting ready to resize itself to fit the screen: \(#function)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        printDebug("View resized to fit the screen: \(#function)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        printDebug(saveButton.frame) // Сами размеры кнопки не отличаются, так-как я задал ей ширину и высоту в соответствии с размерами в фигме. Но отличаются координаты её расположения. Это происходит, потому что весь интерфейс в сториборде подогнан под размеры SE. А в момент отображения экрана, когда как раз срабатывает этот метод, элементы уже расставлены под размеры экрана симулятора.
        printDebug("View added to hierarchy and displayed: \(#function)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        printDebug("View is preparing to be removed from the hierarchy: \(#function)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        printDebug("View has been removed from the hierarchy and is not displayed: \(#function)")
    }

    // MARK: IB Actions
    @IBAction func editLogoButtonPressed() {
        printDebug("Выбери изображение профиля")
        
        changeProfileLogoAlertController()
    }
}

// MARK: - Настройки для ViewController
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
    
    // MARK: - Alert Controller
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
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        profileImageView.image = info[.editedImage] as? UIImage
        
        if profileImageView != nil {
            noProfileImageLabel.isHidden = true
        }

        dismiss(animated: true)
    }
}
