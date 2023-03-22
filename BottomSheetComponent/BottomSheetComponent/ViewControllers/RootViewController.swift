//
//  RootViewController.swift
//  BottomSheetComponent
//
//  Created by Rúben Antunes on 21/03/2023.
//

import Foundation
import UIKit
import SnapKit

class RootViewController: UIViewController {
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Show Bottom Sheet", for: .normal)
        return button
    }()

    private var bottomSheetTransitioningDelegate: UIViewControllerTransitioningDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
    }

    private func setupSubviews() {
        view.backgroundColor = .white

        view.addSubview(button)
        button.addTarget(self, action: #selector(handleShowBottomSheet), for: .touchUpInside)
        button.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(44)
        }
    }

    @objc
    private func handleShowBottomSheet() {
        let viewController = BottomsheetViewController()
        bottomSheetTransitioningDelegate = BottomSheetTransitioningDelegate()
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = bottomSheetTransitioningDelegate
        present(viewController, animated: true, completion: nil)
    }
}

