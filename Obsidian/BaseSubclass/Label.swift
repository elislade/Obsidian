//
//  Label.swift
//  Obsidian
//
//  Created by Eli Slade on 2018-06-29.
//  Copyright © 2018 Eli Slade. All rights reserved.
//

import UIKit

class Label: UILabel {
    var textInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInset))
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += textInset.left + textInset.right
        size.height += textInset.top + textInset.bottom
        return size
    }
}
