//
//  SecurityView.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-04-24.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit

class SecurityView: UIView {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let view = superview {
            frame = view.frame
        }
    }
    
    func fadeOut(completion: ((Bool) -> Void)? = nil) {
        self.animate({ self.alpha = 0 }, completion:completion)
    }
    
    private func animate(_ block: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        DispatchQueue.main.async {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: .curveEaseInOut,
                animations: block,
                completion: completion
            )
        }
    }
}


extension SecurityView: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        label.textColor = theme.primaryForegroundColor
        imageView.tintColor = theme.secondaryForegroundColor
    }
}
