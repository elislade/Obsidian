//
//  AlertController.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-07-27.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit

class AlertController: UIAlertController {
    
    var titleImg: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let img = titleImg {
            setupImageView(img)
        }
    }
    
    func setupImageView(_ img: UIImage) {
        let _view = view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0]
        let v = UIImageView(image: img)
        
        v.contentMode = .scaleAspectFit
        v.translatesAutoresizingMaskIntoConstraints = false
        
        let topLabel = _view.subviews[0]
        
        for cons in _view.constraints {
            if (cons.firstItem as! UIView) == topLabel {
                cons.isActive = false
            }
        }
        
        _view.addSubview(v)
        
        v.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let top = NSLayoutConstraint(item: v, attribute: .top, relatedBy: .equal, toItem: _view, attribute: .top, multiplier: 1.0, constant: 14)
        let bottom = NSLayoutConstraint(item: v, attribute: .bottom, relatedBy: .equal, toItem: topLabel, attribute: .top, multiplier: 1.0, constant: -12)
        let leading = NSLayoutConstraint(item: v, attribute: .leading, relatedBy: .equal, toItem: _view, attribute: .leading, multiplier: 1.0, constant: 10)
        let trailing = NSLayoutConstraint(item: v, attribute: .trailing, relatedBy: .equal, toItem: _view, attribute: .trailing, multiplier: 1.0, constant: -10)
        
        NSLayoutConstraint.activate([top,leading,bottom,trailing])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            ThemeManager.main.drawTheme(from: self)
            UIView.animate(withDuration: 0.3, animations: {
                self.presentingViewController?.view.alpha = 0.5
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentingViewController?.view.tintAdjustmentMode = .dimmed
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.3, animations: {
            self.presentingViewController?.view.alpha = 1
        })
        presentingViewController?.view.tintAdjustmentMode = .normal
    }
}

extension AlertController: Themeable {
    
    func themeDidUpdate(_ theme: Theme) {
        
        for effectView in view.children(ofType: UIVisualEffectView.self, toDepth: 10) {
            if effectView.effect is UIBlurEffect {
                effectView.effect = UIBlurEffect(style: theme.system.blurEffectStyle)
            }
        }
        
        for view in view.children(ofType: UIView.self, toDepth: 9) {
            if view.frame.height > 2 && view.frame.width > 2 {
               view.backgroundColor = .clear
            }
            
            if view.layer.cornerRadius > 0 {
                view.backgroundColor = theme.secondaryBackgroundColor
            }
        }
        
        for label in view.children(ofType: UILabel.self, toDepth: 6) {
            let color = label.font.fontName == ".SFUIText-Semibold" ? theme.primaryForegroundColor : theme.secondaryForegroundColor
            label.textColor = color
        }
    }
    
}
