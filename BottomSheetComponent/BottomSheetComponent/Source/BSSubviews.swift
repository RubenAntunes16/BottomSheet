//
//  BSSubviews.swift
//  BottomSheetComponent
//
//  Created by Rúben Antunes on 21/03/2023.
//

import UIKit

extension BottomSheetPresentationController {

    // ------------------  MARK: Darken View
    internal func setupDarkenView() {
        guard let containerView = containerView else { return }

        let darkenView = UIView()
        darkenView.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        containerView.addSubview(darkenView)
        darkenView.frame = containerView.bounds

        let tapGesture = UITapGestureRecognizer()
        darkenView.addGestureRecognizer(tapGesture)

        tapGesture.addTarget(self, action: #selector(handleTapGesture))

        self.darkenView = darkenView
    }

    @objc
    internal func handleTapGesture() {
        if state == .presented {
            tapDismiss = true
            self.presentedViewController.dismiss(animated: true)
        }
    }

    private func removeDarkenView() {
        darkenView?.removeFromSuperview()
        darkenView = nil
    }


    //------------------  MARK: Pull Bar

    final class PullBar: UIView {

        var grabber: UIView = {
            let view = UIView()
            view.frame.size = GrabberStyle.size
            view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            view.layer.cornerRadius = GrabberStyle.size.height * 0.5
            return view
        }()

        var containerView: UIView

        init(containerView: UIView, backgroundColor: UIColor) {

            self.containerView = containerView

            super.init(frame: .zero)

            self.backgroundColor = backgroundColor

            setupSubviews()
        }

        required init?(coder: NSCoder) {
            preconditionFailure("init(coder:) has not been implemented")
        }

        private func setupSubviews() {

            addSubview(grabber)

            frame.size = CGSize(width: containerView.frame.width, height: GrabberStyle.pullBarHeight)

            // round top left and top right corners
            layer.cornerRadius = GrabberStyle.cornerRadius
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

            grabber.frame.origin.x = containerView.frame.midX - (grabber.frame.size.width / 2)

            grabber.frame.origin.y = frame.midY
        }
    }

    private func setupPullBar() {
        guard let containerView = containerView else { return }

        let pullBarView = PullBar(containerView: containerView, backgroundColor: .systemOrange)

        containerView.addSubview(pullBarView)
        
        pullBar = pullBarView
    }

    private func removePullBar() {
        pullBar?.removeFromSuperview()
        pullBar = nil
    }


    //------------------  MARK: Setup subviews

    internal func setupSubviews() {
        setupDarkenView()
        setupPullBar()
    }

    internal func removeSubviews() {
        removeDarkenView()
        removePullBar()
    }
}

