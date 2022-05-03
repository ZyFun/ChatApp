//
//  VCAnimator.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 03.05.2022.
//

import UIKit

final class VCAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 0.8
    var presenting = true
    var originFrame = CGRect.zero
    
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return duration
    }
    
    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to) else { return }
        guard let profileView = presenting
                ? toView
                : transitionContext.view(forKey: .from) else { return }
        
        let initialFrame = presenting ? originFrame : profileView.frame
        let finalFrame = presenting ? profileView.frame : originFrame

        let xScaleFactor = presenting ?
          initialFrame.width / finalFrame.width :
          finalFrame.width / initialFrame.width

        let yScaleFactor = presenting ?
          initialFrame.height / finalFrame.height :
          finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransform(
            scaleX: xScaleFactor,
            y: yScaleFactor
        )
        
        if presenting {
            profileView.transform = scaleTransform
            profileView.center = CGPoint(
                x: initialFrame.midX,
                y: initialFrame.midY)
            profileView.clipsToBounds = true
        }
        
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(profileView)
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.1
        ) {
            profileView.transform = self.presenting
            ? .identity
            : scaleTransform
            profileView.center = CGPoint(
                x: finalFrame.midX,
                y: finalFrame.midY
            )
        } completion: { _ in
            transitionContext.completeTransition(true)
        }
    }
}
