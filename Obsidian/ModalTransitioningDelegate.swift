//
//  ModalTransitioningDelegate.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-08-27.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit

class ModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    static let master = ModalTransitioningDelegate()
}
