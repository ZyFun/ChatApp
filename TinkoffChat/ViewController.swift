//
//  ViewController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 18.02.2022.
//

import UIKit

class ViewController: UIViewController {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        printDebug("View instance created: \(#function)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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

