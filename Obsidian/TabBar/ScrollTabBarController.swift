//
//  ScrollTabBarController.swift
//  Obsidian
//
//  Created by Eli Slade on 2020-09-15.
//  Copyright © 2020 Eli Slade. All rights reserved.
//

import UIKit

class ScrollTabBarController: UIViewController {

    let gutter: CGFloat = 0
    let columnWidth: CGFloat = 370
    
    var fullWidth: CGFloat {
        guard let ctrls = viewControllers else { return 0 }
        return (columnWidth * CGFloat(ctrls.count)) + (gutter * (CGFloat(ctrls.count) - 1))
    }
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = gutter
        return stack
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.addSubview(stackView)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.backgroundColor = UIColor(displayP3Red: 15/255, green: 15/255, blue: 15/255, alpha: 1)
        scroll.contentInset = view.safeAreaInsets
        scroll.showsHorizontalScrollIndicator = false
        scroll.contentInsetAdjustmentBehavior = .automatic
        scroll.isDirectionalLockEnabled = true
        scroll.delaysContentTouches = true
        return scroll
    }()
    
    var viewControllers: [UIViewController]? = []

    func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        self.viewControllers = viewControllers
        guard let ctrls = viewControllers else { return }
        stackView.switchArrangedViews(ctrls.map{ tabView(for: $0) })
        scrollView.contentSize.width = fullWidth
    }
    
    private func tabView(for ctrl: UIViewController) -> UIView {
        let tab = ScrollTabView(ref: ctrl)
        tab.view.widthAnchor.constraint(equalToConstant: columnWidth).isActive = true
        return tab.view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.constrainBounds(toView: view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewControllers?.forEach{ ctrl in
            ctrl.view.removeFromSuperview()
            ctrl.view.removeConstraints(ctrl.view.constraints)
            ctrl.view.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize.height = view.bounds.height
        stackView.frame.size = scrollView.contentSize
    }
}
