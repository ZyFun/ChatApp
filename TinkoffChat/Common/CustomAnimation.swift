//
//  CustomAnimation.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 30.04.2022.
//

import UIKit

protocol CustomAnimationProtocol {
    func showCoatOfArms(into view: UIView, for coordinate: CGPoint?)
    func deleteCAEmitterLayer(from view: UIView)
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
    
    func deleteCAEmitterLayer(from view: UIView) {
        guard let layer = view.layer.sublayers?.last as? CAEmitterLayer else { return }
        layer.birthRate = 0
        
        let deleteTime = Double(layer.lifetime + 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + deleteTime) {
            layer.removeFromSuperlayer()
        }
    }
    
    func startAnimation(for button: UIButton) {
        UIView.animateKeyframes(
            withDuration: 0.3,
            delay: 0,
            options: [
                .autoreverse,
                .repeat,
                .allowUserInteraction
            ]
        ) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                button.transform = CGAffineTransform(rotationAngle: -Double.pi / 360 * 18)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 1) {
                button.transform = CGAffineTransform(translationX: 0, y: 5)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 1) {
                button.transform = CGAffineTransform(translationX: -5, y: 0)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 1) {
                button.transform = CGAffineTransform(rotationAngle: Double.pi / 360 * 18)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 1) {
                button.transform = CGAffineTransform(translationX: 5, y: 0)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 1) {
                button.transform = CGAffineTransform(translationX: 0, y: -5)
            }
        }
    }
    
    func stopAnimation(for button: UIButton) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [
                .beginFromCurrentState,
                .curveEaseOut
            ]
        ) {
            button.transform = CGAffineTransform.identity
        }
    }
}
