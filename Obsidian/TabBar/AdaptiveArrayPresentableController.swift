//
//  CustomTabViewController.swift
//  Obsidian
//
//  Created by Eli Slade on 2020-09-15.
//  Copyright © 2020 Eli Slade. All rights reserved.
//

import UIKit

protocol ControllerArrayPresentable: UIViewController {
    var viewControllers: [UIViewController]? { get set }
    func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool)
}

class AdaptiveArrayPresentableController<Compact: ControllerArrayPresentable, Full: ControllerArrayPresentable>: UIViewController {

    var viewControllers: [UIViewController] = []
    
    private lazy var compact: Compact = {
        let c = Compact()
        addChild(c)
        return c
    }()
    
    private lazy var full: Full = {
        let c = Full()
        addChild(c)
        return c
    }()
    
    var activeController: ControllerArrayPresentable {
        traitCollection.horizontalSizeClass == .compact ? compact : full
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activeController.viewWillAppear(false)
        view.addSubview(activeController.view)
        activeController.viewDidAppear(false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activeController.setViewControllers(viewControllers, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("did layout active", activeController)
        activeController.view.frame = view.bounds
    }
    
    private func toggle(from ctrlFrom: UIViewController, to ctrlTo: UIViewController) {
        transition(from: ctrlFrom, to: ctrlTo, duration: 0, options: [], animations: nil, completion: { _ in
            self.activeController.setViewControllers(self.viewControllers, animated: false)
        })
    }
    
    private func teardownControllers() {
        for c in viewControllers {
            c.removeFromParent()
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        if newCollection.horizontalSizeClass != traitCollection.horizontalSizeClass {
            teardownControllers()
            
            if newCollection.horizontalSizeClass == .compact {
                toggle(from: full, to: compact)
            } else {
                toggle(from: compact, to: full)
            }
        }
    }
}
