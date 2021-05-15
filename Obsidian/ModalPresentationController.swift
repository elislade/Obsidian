//
//  ModalPresentationController.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-04-19.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit

class ModalPresentationController: UIPresentationController {
    
    let dimView = UIView()
    
    var shouldDismissOnContainerTap = false
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        dimView.alpha = 0
        dimView.backgroundColor = .black
        dimView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(dismiss))
        )
    }
    
    @objc func dismiss() {
        if shouldDismissOnContainerTap {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        if let view = containerView {
            dimView.frame = view.bounds
            view.insertSubview(dimView, at: 0)
        }
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
            self.dimView.alpha = 0.65
            self.presentingViewController.view.tintAdjustmentMode = .dimmed
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
            self.dimView.alpha = 0
            self.presentingViewController.view.tintAdjustmentMode = .normal
        }, completion: nil)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if (!completed) {
            dimView.removeFromSuperview()
        }
    }
    
    override var frameOfPresentedViewInContainerView : CGRect {
        
        var frame = containerView?.bounds ?? presentingViewController.view.frame
        let margin = presentedViewController.view.layoutMargins
        
        var preferredSize = presentingViewController.view.readableContentGuide.layoutFrame.size
        preferredSize.width += margin.left + margin.right
        
        preferredSize.height = presentedViewController.preferredContentSize.height
        
        if preferredSize.height > (frame.height) {
            preferredSize.height = frame.height
        }
        
        if preferredSize.width > frame.width {
            preferredSize.width = frame.width
        }
        
        if preferredSize.width > 640 {
            preferredSize.width = 640
        }
        
        frame.origin.y = frame.height - preferredSize.height
        frame.origin.x = (frame.width - preferredSize.width) / 2
        frame.size = preferredSize
        
        return frame
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        if let presView = presentedView {
            presView.frame = frameOfPresentedViewInContainerView
            mask(view: presView)
        }
    }
    
    func mask(view: UIView) {
        // let maskLayer = CAShapeLayer()
        // let path = roundedCornerPath(rect: view.bounds, cornerSize: 8)
        // maskLayer.path = path.cgPath
        // maskLayer.frame = view.bounds
        // view.layer.mask = maskLayer
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func roundedCornerPath(rect: CGRect, cornerSize: CGFloat) -> UIBezierPath {
        return UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: cornerSize.cgSize
        )
    }
    
    override func containerViewDidLayoutSubviews() {
        if let view = containerView {
            dimView.frame = view.bounds
            
            if let presView = presentedView {
                presView.frame = frameOfPresentedViewInContainerView
                mask(view: presView)
            }
        }
    }
    
}
