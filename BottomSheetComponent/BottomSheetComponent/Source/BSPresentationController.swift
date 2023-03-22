//
//  BSPresentationController.swift
//  BottomSheetComponent
//
//  Created by Rúben Antunes on 21/03/2023.
//

import Foundation

import UIKit

class BottomSheetPresentationController: UIPresentationController {

    /// This var is from UIPresentController and we use that in order to resize the content
    override var frameOfPresentedViewInContainerView: CGRect {
        targetFrameForPresentedView()
    }
    /// This don't allow the bottom sheet to cover the full screen
    override var shouldPresentInFullscreen: Bool {
        false
    }

    var tapDismiss: Bool = false
    private var originalHeight: CGFloat = 0

    internal var state: State = .dismissed

    internal var darkenView: UIView?
    internal var pullBar: UIView?

    internal var interactionController: UIPercentDrivenInteractiveTransition?

    // Expose interactor controller to transitioning delegate
    var interactiveTransitioning: UIViewControllerInteractiveTransitioning? {
        interactionController
    }

    // ---------------- MARK: - Scrollable Variables
    internal var trackedScrollView: UIScrollView?

    internal var isInteractiveTransitionCanBeHandled: Bool {
        isDragging
    }

    internal var isDragging = false
    internal var overlayTranslation: CGFloat = 0
    internal var scrollViewTranslation: CGFloat = 0
    internal var lastContentOffsetBeforeDragging: CGPoint = .zero
    internal var didStartDragging = false

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    // MARK: Update Bottom Sheet Height
    // Position Presented View based on preferredContentSize
    private func targetFrameForPresentedView() -> CGRect {
        guard let containerView = containerView else { return .zero }

        // Get the limits so the view doesn't overlay those limits
        let windowInsets = presentedView?.window?.safeAreaInsets ?? .zero

        let preferredHeight = presentedViewController.preferredContentSize.height + windowInsets.bottom

        let maxHeight = containerView.bounds.height - windowInsets.top

        let height = min(preferredHeight, maxHeight)

        return .init(
            x: 0,
            y: (containerView.bounds.height - height),
            width: containerView.bounds.width,
            height: height
        )
    }

    override func presentationTransitionWillBegin() {
        state = .presenting

        setupSubviews()
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if completed {
            interactionController = UIPercentDrivenInteractiveTransition()
            setupGestures()
            state = .presented
        } else {
            state = .dismissed
        }
    }

    override func dismissalTransitionWillBegin() {
        state = .dismissing
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            removeSubviews()
            state = .dismissed
        } else {
            state = .presented
        }
    }

    // ------------------- MARK: Swipe Down Gesture

    private func setupGestures() {
        setupPanGesture(for: presentedView)
        setupPanGesture(for: pullBar)
    }

    private func setupPanGesture(for view: UIView?) {
        guard let view = view else { return }

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panRecognizer)
    }

    @objc
    private func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {

        guard
            let presentedView = presentedView,
            let containerView = containerView
        else { return }

        switch panGesture.state {
        case .began:
            self.originalHeight = containerView.bounds.height - presentedView.frame.height
        case .changed:
            processPanGestureChanged(panGesture, presentedView: presentedView)
        case .ended:
            processPanGestureEnded(panGesture)
        case .cancelled:
            processPanGestureCancelled(panGesture)
        default:
            break
        }
    }

    // MARK: Gesture: Canged
    private func processPanGestureChanged(_ panGesture: UIPanGestureRecognizer, presentedView: UIView) {
        guard
            let pullBar = pullBar else { return }
        let translation = panGesture.translation(in: presentedView)
        var size: CGSize = .zero
        print(translation.y)
        print("MinY: \(presentedView.frame.minY)")
        print("Oiginal height: \(originalHeight) | atual: \(presentedView.frame.height)")

        if translation.y < 0 {
            size = CGSize(width: presentedView.frame.width,
                          height: presentedView.frame.height + abs(translation.y))
        } else {
            size = CGSize(width: presentedView.frame.width,
                          height: presentedView.frame.height - abs(translation.y))
        }

        if originalHeight < presentedView.frame.minY {
            size = CGSize(width: presentedView.frame.width,
                         height: presentedView.frame.height)
        }

        presentedView.frame = CGRect(
            origin: CGPoint(x: presentedView.frame.minX,
                            y: presentedView.frame.minY + translation.y),
            size: size)

        pullBar.center = CGPoint(x: pullBar.center.x, y: pullBar.center.y + translation.y)

        panGesture.setTranslation(.zero, in: presentedView.superview)
        updateInteractionControllerProgress(verticalTranslation: translation.y)
    }

    internal func updateInteractionControllerProgress(verticalTranslation: CGFloat) {
        guard let presentedView = presentedView else { return }

        let progress = verticalTranslation / presentedView.bounds.height
        interactionController?.update(progress)
    }

    // MARK: Gesture: Ended
    private func processPanGestureEnded(_ panGesture: UIPanGestureRecognizer) {
        let velocity = panGesture.velocity(in: presentedView)
        let translation = panGesture.translation(in: presentedView)
        endInteractiveTransition(verticalVelocity: velocity.y, verticalTranslation: translation.y)
    }

    internal func endInteractiveTransition(verticalVelocity: CGFloat, verticalTranslation: CGFloat) {
        guard let presentedView = presentedView else { return }

        // calculate where the bottom sheet will stop based on velocity and distance of the gesture
        let deceleration: CGFloat = 800.0 * (verticalVelocity > 0 ? -1.0 : 1.0)
        let finalProgress = (verticalTranslation - 0.5 * verticalVelocity * verticalVelocity / deceleration)
            / presentedView.bounds.height
        let isThresholdPassed = finalProgress < 0.5

        endInteractiveTransition(isCancelled: isThresholdPassed)
    }

    internal func endInteractiveTransition(isCancelled: Bool) {
        if isCancelled {
            guard
                let presentedView = self.presentedView,
                let pullBar = self.pullBar else {
                return
            }

            interactionController?.cancel()

            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           options: .curveLinear,
                           animations: { [weak self] in
                guard
                    let self = self else {
                    return
                }

                presentedView.frame = self.frameOfPresentedViewInContainerView
                pullBar.frame.origin.y = presentedView.frame.minY - GrabberStyle.pullBarHeight
            })
        } else {
            guard
                let presentedView = presentedView,
                let containerView = containerView,
                let pullBar = pullBar,
                let darkenView = darkenView
            else { return }

            interactionController?.finish()

            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveLinear,
                           animations: {
                presentedView.frame.origin = CGPoint(x: 0, y: containerView.bounds.height)
                darkenView.alpha = 0
                pullBar.frame.origin.y = presentedView.frame.minY - GrabberStyle.pullBarHeight
            }, completion: {_ in
                self.presentedViewController.dismiss(animated: true)
            })
        }
        interactionController = nil
    }

    // MARK: Gesture: Cancelled
    private func processPanGestureCancelled(_ panGesture: UIPanGestureRecognizer) {
        endInteractiveTransition(isCancelled: true)
    }

}
