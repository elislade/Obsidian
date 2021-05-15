//
//  SymbolControllerPresentable.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-05-02.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit

protocol Storyboarded {
    var storyboard: UIStoryboard? { get }
}

protocol ViewControllerPresentable {
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
    func dismiss(animated flag: Bool, completion: (() -> Swift.Void)?)
}

protocol SymbolControllerPresentable: ViewControllerPresentable, Storyboarded {}

extension SymbolControllerPresentable {
    func presentSymbolCtrl(with symbolId: Int?, embedInNav shouldEmbedInNav: Bool = true) {
        let sb = storyboard != nil ? storyboard! : UIStoryboard(name: "Main", bundle: nil)
        let ctrl = sb.initVC(SymbolViewController.self)
        
        ctrl.viewData = symbolId

        let presCtrl = shouldEmbedInNav ? UINavigationController(rootViewController: ctrl) : ctrl
        presCtrl.modalPresentationStyle = .custom
        presCtrl.transitioningDelegate = ModalTransitioningDelegate.master
        
        if let nav = presCtrl as? UINavigationController {
            nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
            nav.navigationBar.isTranslucent = true
        }
        
        present(presCtrl, animated: true, completion: nil)
    }
}
