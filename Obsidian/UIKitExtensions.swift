//
//  UIKitExtensions.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-06-29.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit

extension UIApplication {
    func openSettings(completion: ((Bool) -> Void)?) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            completion?(false)
            return
        }
        
        open(url, options: [:], completionHandler: completion)
    }
}

extension UIViewController {
    var topPresentedViewController: UIViewController {
        if let pres = presentedViewController {
            return pres.topPresentedViewController
        } else {
            return self
        }
    }
}

extension UIStoryboard {
    func initVC<T: UIViewController>(_ type: T.Type) -> T {
        return self.instantiateViewController(withIdentifier: "\(T.self)") as! T
    }
}

extension UIView {
    public class func fromNib(_ nibName: String? = nil) -> Self {
        func fromNibHelper<T>(nibName: String?) -> T where T : UIView {
            let bundle = Bundle(for: T.self)
            let name = nibName ?? String(describing: T.self)
            return bundle.loadNibNamed(name, owner: self, options: nil)?.first as? T ?? T()
        }
        return fromNibHelper(nibName: nibName)
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
    }
    
    func constrainBounds(toView view: UIView){
        let attrs: [NSLayoutConstraint.Attribute] = [.top, .bottom, .leading, .trailing]
        
        NSLayoutConstraint.activate(attrs.map{ attr in
            NSLayoutConstraint(
                item: self,
                attribute: attr,
                relatedBy: .equal,
                toItem: view,
                attribute: attr,
                multiplier: 1.0,
                constant: 0
            )
        })
    }
}

extension UIViewController: Treeable {}

extension UIView: DarwingEffect { }
extension UIView: Treeable {
    var parent: UIView? { superview }
    var children: [UIView] { subviews }
}

extension CALayer: Treeable {
    var parent: CALayer? { superlayer }
    var children: [CALayer] { sublayers ?? [] }
}

extension CGFloat {
    var cgSize: CGSize { CGSize(width: self, height: self) }
}

extension UIStackView {
    func removeArrangedViews(){
        for v in arrangedSubviews {
            removeArrangedSubview(v)
        }
    }
    
    func switchArrangedViews(_ views: [UIView]) {
        removeArrangedViews()
        for v in views { addArrangedSubview(v) }
    }
}
