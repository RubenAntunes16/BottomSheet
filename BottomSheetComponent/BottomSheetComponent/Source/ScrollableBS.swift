//
//  ScrollableBS.swift
//  BottomSheetComponent
//
//  Created by Rúben Antunes on 21/03/2023.
//

import UIKit

public protocol ScrollableBottomSheetPresentedController: AnyObject {
    var scrollView: UIScrollView? { get }
}

extension BottomSheetPresentationController: UIScrollViewDelegate {

    private func setupScrollTrackingIfNeeded() {
        trackScrollView(inside: presentedViewController)
    }

    private func trackScrollView(inside viewController: UIViewController) {
        guard
            let scrollableViewController = viewController as? ScrollableBottomSheetPresentedController,
            let scrollView = scrollableViewController.scrollView
        else {
            return
        }

        trackedScrollView?.delegate = nil
        scrollView.multicastingDelegate.addDelegate(self)
        self.trackedScrollView = scrollView
    }

    private func removeScrollTrackingIfNeeded() {
        trackedScrollView?.multicastingDelegate.removeDelegate(self)
        trackedScrollView = nil
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true
    }

    // this functions is used to verify if is needs to start or conitnue the scroll
    private func shouldDragOverlay(following scrollView: UIScrollView) -> Bool {
        guard scrollView.isTracking, isInteractiveTransitionCanBeHandled else {
            return false
        }

        if let percentComplete = interactionController?.percentComplete {
            if percentComplete.isEqual(to: 0) {
                return scrollView.isContentOriginInBounds && scrollView.scrollsDown
            }

            return true
        } else {
            return scrollView.isContentOriginInBounds && scrollView.scrollsDown
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let previousTranslation = scrollViewTranslation
        scrollViewTranslation = scrollView.panGestureRecognizer.translation(in: scrollView).y

        didStartDragging = shouldDragOverlay(following: scrollView)
        if didStartDragging {
            startInteractiveTransitionIfNeeded()
            overlayTranslation += scrollViewTranslation - previousTranslation

            // Update scrollView contentInset without invoking scrollViewDidScroll(_:)
            scrollView.bounds.origin.y = -scrollView.adjustedContentInset.top

            updateInteractionControllerProgress(verticalTranslation: overlayTranslation)
        } else {
            lastContentOffsetBeforeDragging = scrollView.panGestureRecognizer.translation(in: scrollView)
        }
    }

    private func startInteractiveTransitionIfNeeded() {
        guard interactionController == nil else { return }
    }

    public func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if didStartDragging {
            let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView)
            let translation = scrollView.panGestureRecognizer.translation(in: scrollView)
            endInteractiveTransition(
                verticalVelocity: velocity.y,
                verticalTranslation: translation.y - lastContentOffsetBeforeDragging.y
            )
        } else {
            endInteractiveTransition(isCancelled: true)
        }

        overlayTranslation = 0
        scrollViewTranslation = 0
        lastContentOffsetBeforeDragging = .zero
        didStartDragging = false
        isDragging = false
    }
}

extension UIScrollView {
    var scrollsUp: Bool {
        panGestureRecognizer.velocity(in: nil).y < 0
    }

    var scrollsDown: Bool {
        !scrollsUp
    }

    var isContentOriginInBounds: Bool {
        contentOffset.y <= -adjustedContentInset.top
    }
}
