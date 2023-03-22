//
//  BSViewController.swift
//  BottomSheetComponent
//
//  Created by Rúben Antunes on 21/03/2023.
//

import Foundation
import UIKit
import SnapKit

class BottomsheetViewController: UIViewController {

    private let contentSizeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.text = "Swipe down or tap in the dimmer View to Dismiss"
        return label
    }()

    private let _scrollView = UIScrollView()
    private let scrollContentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        preferredContentSize = CGSize(width: UIScreen.main.bounds.height, height: 500)
    }

    private func setupSubviews() {
        view.backgroundColor = .systemOrange


        view.addSubview(_scrollView)
        _scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        _scrollView.addSubview(scrollContentView)
        scrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(600)
        }

        scrollContentView.addSubview(contentSizeLabel)
        contentSizeLabel.snp.makeConstraints {
            $0.leading.top.trailing.bottom.equalToSuperview()
        }
    }
}

extension BottomsheetViewController: ScrollableBottomSheetPresentedController {
    var scrollView: UIScrollView? {
        _scrollView
    }
}
