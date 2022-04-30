//
//  CustomAnimation.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 30.04.2022.
//

import UIKit

protocol CustomAnimationProtocol {
    func startAnimation(for button: UIButton)
    func stopAnimation(for button: UIButton)
}

class CustomAnimation: CustomAnimationProtocol {
    func startAnimation(for button: UIButton) {
        let rotationZ: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationZ.fromValue = -Double.pi / 360 * 18
        rotationZ.byValue = 0
        rotationZ.toValue = Double.pi / 360 * 18
        
        let position = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        position.values = [
            [button.center.x - 5, button.center.y],
            [button.center.x, button.center.y + 5],
            [button.center.x + 5, button.center.y],
            [button.center.x, button.center.y - 5]
        ]
        
        let group = CAAnimationGroup()
        group.duration = 0.3
        group.autoreverses = true
        group.repeatCount = .infinity
        group.animations = [position, rotationZ]

        button.layer.add(group, forKey: nil)
    }
    
    func stopAnimation(for button: UIButton) {
        button.layer.removeAllAnimations()
    }
}
