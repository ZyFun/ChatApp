//
//  VCAnimator.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 03.05.2022.
//

import UIKit

class VCAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 0.8
    var presenting = true
    var originFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        containerView.addSubview(toView)
        toView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(
          withDuration: duration,
          animations: {
            toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
          },
          completion: { _ in
            transitionContext.completeTransition(true)
          }
        )
    }
}
