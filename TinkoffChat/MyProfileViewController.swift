//
//  ViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 18.02.2022.
//

import UIKit

class MyProfileViewController: UIViewController {
    
    // MARK: IB Outlets
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var logoProfileImageView: UIImageView!
    @IBOutlet weak var editLogoButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - LifeCycle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        printDebug("View instance created: \(#function)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        printDebug("View has been loaded into memory: \(#function)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        printDebug("View will be added to the hierarchy from memory: \(#function)")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        printDebug("View is getting ready to resize itself to fit the screen: \(#function)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        printDebug("View resized to fit the screen: \(#function)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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

}

extension MyProfileViewController {
    func setup() {
        setupUI()
    }
    
    func setupUI() {
        setupTopBarView()
        setupImage()
        setupButtons()
    }
    
    func setupTopBarView() {
        topBarView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    }
    
    func setupImage() {
        logoProfileImageView.backgroundColor = #colorLiteral(red: 0.8941176471, green: 0.9098039216, blue: 0.168627451, alpha: 1)
        logoProfileImageView.layer.cornerRadius = logoProfileImageView.frame.height / 2
    }
    
    func setupButtons() {
        saveButton.backgroundColor = #colorLiteral(red: 0.9647058845, green: 0.9647058845, blue: 0.9647058845, alpha: 1)
        saveButton.layer.cornerRadius = 14
        saveButton.titleLabel?.font = .systemFont(ofSize: 19)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        
        editLogoButton.backgroundColor = #colorLiteral(red: 0.2470588235, green: 0.4705882353, blue: 0.9411764706, alpha: 1)
        editLogoButton.tintColor = .white
        editLogoButton.layer.cornerRadius = editLogoButton.frame.height / 2
    }
}

