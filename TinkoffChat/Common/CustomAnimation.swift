//
//  CustomAnimation.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 30.04.2022.
//

import UIKit

protocol CustomAnimationProtocol {
    func showCoatOfArms(into view: UIView, for coordinate: CGPoint?)
    func startAnimation(for button: UIButton)
    func stopAnimation(for button: UIButton)
}

class CustomAnimation: CustomAnimationProtocol {
    private lazy var coatOfArmsCell: CAEmitterCell = {
        var coatOfArmsCell = CAEmitterCell()
        coatOfArmsCell.contents = UIImage(named: "coatOfArms")?.cgImage
        coatOfArmsCell.scale = 0.03
        coatOfArmsCell.emissionRange = .pi
        coatOfArmsCell.lifetime = 5
        coatOfArmsCell.birthRate = 20
        coatOfArmsCell.alphaSpeed = -0.2
        coatOfArmsCell.velocity = 10
        coatOfArmsCell.velocityRange = 5
        coatOfArmsCell.yAcceleration = -30
        coatOfArmsCell.spin = CGFloat.random(in: -0.5...0.5)
        coatOfArmsCell.spinRange = 1.0
        return coatOfArmsCell
    }()
    
    func showCoatOfArms(into view: UIView, for coordinate: CGPoint?) {
        guard let coordinate = coordinate else {
            Logger.error("Координаты не распознаны")
            return
        }
        
        let coatOfArmsCellLayer = CAEmitterLayer()
        coatOfArmsCellLayer.lifetime = coatOfArmsCell.lifetime  // нужно для того, чтобы задать время удаления слоя
        coatOfArmsCellLayer.emitterPosition = CGPoint(x: coordinate.x, y: coordinate.y)
        coatOfArmsCellLayer.beginTime = CACurrentMediaTime()
        coatOfArmsCellLayer.emitterCells = [coatOfArmsCell]
        view.layer.addSublayer(coatOfArmsCellLayer)
    }
    
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
