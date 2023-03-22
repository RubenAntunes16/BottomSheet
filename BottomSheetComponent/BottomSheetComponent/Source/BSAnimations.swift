//
//  BSAnimations.swift
//  BottomSheetComponent
//
//  Created by Rúben Antunes on 21/03/2023.
//

import UIKit

extension BottomSheetPresentationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let sourceVC = transitionContext.viewController(forKey: .from),
            let destinationVC = transitionContext.viewController(forKey: .to),
            let sourceView = sourceVC.view,
            let destinationView = destinationVC.view
        else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView

        let isPresentingBottomSheet = destinationVC.isBeingPresented

        let presentedView = isPresentingBottomSheet ? destinationView : sourceView

        if isPresentingBottomSheet {
            containerView.addSubview(destinationView)

            destinationView.frame = containerView.bounds
        }

        sourceView.layoutIfNeeded()
        destinationView.layoutIfNeeded()

        let frameInContainer = frameOfPresentedViewInContainerView
        let offscreenFrame = CGRect(
            origin: CGPoint(
                x: 0,
                y: containerView.bounds.height
            ),
            size: sourceView.frame.size
        )

        presentedView.frame = isPresentingBottomSheet ? offscreenFrame : frameInContainer
        darkenView?.alpha = isPresentingBottomSheet ? 0 : 1

        pullBar?.frame.origin.y = presentedView.frame.minY - GrabberStyle.pullBarHeight

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       options: transitionContext.isInteractive ? .curveLinear : .curveEaseInOut,
                       animations: { [weak self] in
            guard let self = self else {
                transitionContext.completeTransition(false)
                return
            }

            self.presentedView?.frame = isPresentingBottomSheet ? frameInContainer : offscreenFrame
            self.pullBar?.frame.origin.y = presentedView.frame.minY - GrabberStyle.pullBarHeight
            self.darkenView?.alpha = isPresentingBottomSheet ? 1 : 0
        }, completion: {  completed in
            transitionContext.completeTransition(completed && !transitionContext.transitionWasCancelled)
        })


    }


}
